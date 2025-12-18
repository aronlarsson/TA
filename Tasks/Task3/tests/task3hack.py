import psycopg2
import os
import sys
#from tabulate import tabulate

class CompareError(Exception):
    pass

class NoErrorError(Exception):
    pass

class Tester:

    def __init__(self, conn):
        self.conn=conn
        self.log=[]

    def setSchema(self, sch):
        with self.conn.cursor() as curr:
            curr.execute(f"SET search_path TO {sch}")

    def clearSchema(self, sch):
        with self.conn.cursor() as cur:
            try:
                cur.execute(f"DROP SCHEMA {sch} CASCADE;")
            except psycopg2.Error as err:
                # This tends to happen for the first submission tested
                print("warning when dropping schema: "+ str(err))
            cur.execute(f"CREATE SCHEMA {sch};")

    def selectBoth(self, q):
        return (self.select("reference", q), self.select("test", q))

    def select(self, sch, q):
        with self.conn.cursor() as curr:
            curr.execute(q.format(schema=sch))
            return curr.fetchall()

    def updateBoth(self, q):
        step = len([t for t in self.log if t.startswith("*test number")])+1
        self.log.append(f'*test number {step}:{q.format(schema="public")}')
        rrows = self.update("reference", q)
        trows = self.update("test", q)
        if(trows != rrows):
            self.log.append("WARNING: incorrect number of affected rows (typically due to incorrect return value)")
            #raise RowcountError()
        self.compare()

    def update(self, sch, q):
        self.setSchema(sch)
        with self.conn.cursor() as curr:
            curr.execute(q.format(schema=sch))
            return curr.rowcount

    def fail(self, q):
        step = len([t for t in self.log if t.startswith("*test number")])+1
        self.log.append(f'*test number {step} (should fail):{q.format(schema="public")}')
        self.setSchema("test")
        try:
            with self.conn.cursor() as tcur:
                tcur.execute(q.format(schema="test"))
                raise NoErrorError()
        except psycopg2.Error as e:
            #print(e)
            pass

    def compare(self):
        conn = self.conn
        with conn.cursor() as rcur, conn.cursor() as tcur:
            rcur.execute("""SELECT course, student, status, position FROM reference.Registrations NATURAL LEFT JOIN reference.WaitingList ORDER BY (course, student)""")
            rres = rcur.fetchall()
            
            #print()
            #print("-- " + self.log[-1])
            #print(tabulate(rres, headers = ['course', 'student', 'status', 'position']))
            
            tcur.execute("""SELECT course, student, status, position FROM test.Registrations NATURAL LEFT JOIN test.WaitingList ORDER BY (course, student)""")
            tres = tcur.fetchall()
            
            if not (rres == tres):
                e = CompareError()
                e.tres=tres
                e.rres=rres
                raise e

    def runfile(self, path):
        with self.conn.cursor() as cur:
            cur.execute(open(path, "r").read())

    def task2checks(self, f):
        self.log = ["Initiating tests"]
        
        try:
            self.clearSchema("reference")
            self.clearSchema("test")

            file_dir = os.path.dirname(os.path.abspath(__file__))

            self.setSchema("reference")
            self.runfile(os.path.join(file_dir, "tables.sql"))
            self.runfile(os.path.join(file_dir, "views.sql"))
            self.runfile(os.path.join(file_dir, "triggers.sql"))
            self.runfile(os.path.join(file_dir, "inserts.sql"))

            self.setSchema("test")
            self.log.append("*Running tables.sql")
            self.runfile(os.path.join(f, "tables.sql"))
            self.log.append("*Running views.sql")
            self.runfile(os.path.join(f, "views.sql"))
            self.log.append("*Running inserts.sql")
            self.runfile(os.path.join(f, "inserts.sql"))

            (refCount, testCount) = self.selectBoth(""" SELECT COUNT(*) FROM information_schema.tables WHERE table_schema='{schema}' AND table_type='BASE TABLE' """)

            if(refCount[0] != testCount[0]):
                print(f)
                print(refCount[0][0])
                print(testCount[0][0])
                print(sorted(self.select("reference", "SELECT table_name FROM information_schema.tables WHERE table_schema='{schema}' AND table_type='BASE TABLE'")))

        except psycopg2.Error as err:
            print(f'{f}: SQL error when running:')
            print(self.log[-1])
            print(str(err))
        except FileNotFoundError as err:
            print(f + ": missing file")

    def task3check(self, f):
        self.log = ["Initiating tests"]
        opStart=0
        try:
            print(f, file=sys.stderr)
            self.clearSchema("reference")
            self.clearSchema("test")
            
            current_dir = os.path.dirname(os.path.abspath(__file__))

            self.setSchema("reference")
            self.runfile(os.path.join(current_dir, "tables.sql"))
            self.runfile(os.path.join(current_dir, "views.sql"))
            self.runfile(os.path.join(current_dir, "triggers.sql"))   
            self.runfile(os.path.join(current_dir, "inserts.sql"))
        
            self.setSchema("test")
            self.log.append("*Running tables.sql")
            self.runfile(os.path.join(f, "tables.sql"))
            self.log.append("*Running views.sql")
            self.runfile(os.path.join(f, "views.sql"))
            self.log.append("*Running triggers.sql")
            self.runfile(os.path.join(f, "triggers.sql"))
            self.log.append("*Running inserts.sql")
            self.runfile(os.path.join(f, "inserts.sql"))
            
            self.setSchema("public") # just to find bugs

            self.log.append("*Testing initial setup")
            self.compare()      
            
            self.log.append("*Initial tests completed") 
            
            """
            01. register s1 c1 -> registered
            02. register s5 c3 -> waiting list (position 1)
            03. register s6 c3 -> waiting list (position 2)
            04. register s6 c2 -> registered
            05. register s2 c2 -> waiting list (position 1)
            06. register s5 c4 -> registered

            07. register s4 c1 -> failed (already passed)
            08. register s1 c1 -> failed (already registered)
            09. register s3 c2 -> failed (already waiting)
            10. register s6 c4 -> failed (missing prereq)
            11. register s2 c4 -> failed (missing prereq)

            12. unregister s1 from all courses -> delete 2, no change in waiting list
            13. register s1 c3 -> waiting list (position 3)
            14. unregister s6 from c3 -> delete 1, remove from waiting
            15. unregister s3 from c3 -> delete 1, move s5 to registered
            16. unregister s5 from c3 -> delete 1, move s1 to registered
            17. register s2 c1 -> registered"""
            
            
            self.updateBoth("INSERT INTO {schema}.Registrations VALUES ('1111111111', 'CCC111')") # unlimited course, no grade
            self.updateBoth("INSERT INTO {schema}.Registrations VALUES ('5555555555', 'CCC333')") # limited course, overfull
            self.updateBoth("INSERT INTO {schema}.Registrations VALUES ('6666666666', 'CCC333')") # limited course, overfull
            self.updateBoth("INSERT INTO {schema}.Registrations VALUES ('6666666666', 'CCC222')") # limited course, not full
            self.updateBoth("INSERT INTO {schema}.Registrations VALUES ('2222222222', 'CCC222')") # limited course, full, U
            self.updateBoth("INSERT INTO {schema}.Registrations VALUES ('5555555555', 'CCC444')") # unlimited course, prerequisites
            
            self.fail("INSERT INTO {schema}.Registrations VALUES ('4444444444', 'CCC111')") # missing passed
            self.fail("INSERT INTO {schema}.Registrations VALUES ('1111111111', 'CCC111')") # Already registered
            self.fail("INSERT INTO {schema}.Registrations VALUES ('5555555555', 'CCC333')") # Already waiting
            self.fail("INSERT INTO {schema}.Registrations VALUES ('6666666666', 'CCC444')") # missing prereq
            self.fail("INSERT INTO {schema}.Registrations VALUES ('2222222222', 'CCC444')") # missing prereq
            
            self.updateBoth("DELETE FROM {schema}.Registrations WHERE student='1111111111'") # no longer overfull
            self.updateBoth("INSERT INTO {schema}.Registrations VALUES ('1111111111', 'CCC333')") # position 3
            self.updateBoth("DELETE FROM {schema}.Registrations WHERE student='6666666666' AND course='CCC333'")
            self.updateBoth("DELETE FROM {schema}.Registrations WHERE student='3333333333' AND course='CCC333'")
            self.updateBoth("DELETE FROM {schema}.Registrations WHERE student='5555555555' AND course='CCC333'")
            self.updateBoth("DELETE FROM {schema}.Registrations WHERE student='1111111111' AND course='CCC333'")
            self.updateBoth("INSERT INTO {schema}.Registrations VALUES ('2222222222', 'CCC111')")
            
            for t in set(self.log):
                if t.startswith("WARNING:"):
                    print(f'{f}:{t}')
            
            print(f'{f}:Passed tests')
            
        except psycopg2.Error as err:
            print(f'{f}: SQL error when running:')
            print(self.log[-1])
            print(str(err))
        except FileNotFoundError as err:
            print(f + ": missing file")
        except CompareError as err: 
            print(f'{f}: incorrect table contents after running:')
            print(self.log[-1])
            print("Expected: "+str(err.rres))
            print("Found   : "+str(err.tres))
        except NoErrorError as err:
            print(f'{f}: not giving error when it should:')
            print(self.log[-1])
      

#def tab(tab):
#    tabulate(tab)
    #print()
    #for row in tab:
    #   print(row)



def main():
    if len(sys.argv) < 2:
        raise Exception("Please provide path to group folders")
    group_folder = sys.argv[1]
    if not os.path.isdir(group_folder):
        raise Exception(f"Provided path {group_folder} is not a directory")
    # r is for reference, this connection has a correct solution
    rconn = psycopg2.connect(
        host="localhost",
        user="postgres",
        password="postgres")
    rconn.autocommit = True
    
    tst = Tester(rconn)

    tst.task3check(group_folder)

    # if active(group_folder):
    #     #tst.task2checks(group_folder)
    #     print("Running Task 3 checks:")
    #     tst.task3check(group_folder)
    #     print("")


# false for submissions that have already been graded
def active(f):
    content = open(os.path.join(f, "FIRE_INFO.txt"), "r", encoding="UTF-8").read()
    return ("review" not in content)


if __name__ == "__main__":
    try:
        main()
    except Exception as e:
        print("Error when running tests: " + str(e))
