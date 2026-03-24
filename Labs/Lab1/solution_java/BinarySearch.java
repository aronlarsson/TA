/**
 * Different versions of binary search.
 * All search functions share the following description.
 *
 * Arguments:
 * - The first argument `array` is a sorted array of comparable items.
 * - The second argument `value` is the value to search for.
 *
 * All arguments and array values are not null (no need to check).
 *
 * Complexity requirement:
 * The function makes O(log(n)) comparisons where n is the length of `array`.
 */
public class BinarySearch {

    /**
     * Check if the array contains the given value.
     * Iterative version.
     * @return `true` if `value` is in `array`, otherwise `false` (duh!).
     */
    //---------- TASK 1: Iterative version of binary search -------------------//
    public static<V extends Comparable<? super V>> boolean containsIterative(V[] array, V value) {
        int low = 0;
        int high = array.length - 1;       // Inclusive-exclusive indexing: high = array.length
        while (low <= high) {
            int mid = (low + high) / 2;
            V midValue = array[mid];
            int cmp = value.compareTo(midValue);
            if (cmp > 0) {
                low = mid + 1;
            } else if (cmp < 0) {
                high = mid - 1;            // Inclusive-exclusive indexing: high = mid
            } else {
                return true;
            }
        }
        return false;
    }
    //---------- END TASK 1 ---------------------------------------------------//

    /**
     * Check if the array contains the given value.
     * Recursive version.
     */
    //---------- TASK 2: Recursive version of binary search -------------------//
    public static<V extends Comparable<? super V>> boolean containsRecursive(V[] array, V value) {
        return containsRecursiveHelper(array, value, 0, array.length - 1);
    }

    private static<V extends Comparable<? super V>> boolean containsRecursiveHelper(V[] array, V value, int low, int high) {
        if (low > high) {
            return false;
        }
        int mid = (low + high) / 2;
        V midValue = array[mid];
        int cmp = value.compareTo(midValue);
        if (cmp > 0) {
            return containsRecursiveHelper(array, value, mid + 1, high);
        } else if (cmp < 0) {
            return containsRecursiveHelper(array, value, low, mid - 1);
        } else {
            return true;
        }
    }
    //---------- END TASK 2 ---------------------------------------------------//

    /**
     * Search for the *first* position in the array that matches the given value.
     * @return the smallest index whose array element matches `value`, or -1 if no such index exists.
     */
    //---------- TASK 3: Binary search returning the first index --------------//
    public static<V extends Comparable<? super V>> int firstIndexOf(V[] array, V value) {
        // Select the default solution.
        return firstIndexOfIterative1(array, value);
    }

    // Iterative solution, version 1
    public static<V extends Comparable<? super V>> int firstIndexOfIterative1(V[] array, V value) {
        int result = -1;
        int low = 0;
        int high = array.length - 1;
        while (low <= high) {
            int mid = (low + high) / 2;
            V midValue = array[mid];
            int cmp = value.compareTo(midValue);
            if (cmp > 0) {
                low = mid + 1;
            } else if (cmp < 0) {
                high = mid - 1;
            } else {
                // We remember this as the best match so far.
                result = mid;
                high = mid - 1;
            }
        }
        return result;
    }

    // Iterative solution, version 2
    public static<V extends Comparable<? super V>> int firstIndexOfIterative2(V[] array, V value) {
        int low = 0;
        int high = array.length - 1;
        while (low <= high) {
            int mid = (low + high) / 2;
            V midValue = array[mid];
            int cmp = value.compareTo(midValue);
            if (cmp > 0) {
                low = mid + 1;
            } else if (cmp < 0) {
                high = mid - 1;
            } else if (mid > 0 && value.equals(array[mid - 1])) {
                // We found a match, but it's not the first one.
                high = mid - 1;
            } else {
                return mid;
            }
        }
        return -1;
    }

    // Recursive solution, version 1 - tail recursive, similar to iterative version 1.
    public static<V extends Comparable<? super V>> int firstIndexOfRecursive1(V[] array, V value) {
        return firstIndexOfRecursiveHelper1(array, value, 0, array.length - 1, -1);
    }

    private static<V extends Comparable<? super V>> int firstIndexOfRecursiveHelper1(V[] array, V value, int low, int high, int result) {
        if (low > high) {
            return result;
        }
        int mid = (low + high) / 2;
        V midValue = array[mid];
        int cmp = value.compareTo(midValue);
        if (cmp < 0) {
            return firstIndexOfRecursiveHelper1(array, value, low, mid - 1, result);
        } else if (cmp > 0) {
            return firstIndexOfRecursiveHelper1(array, value, mid + 1, high, result);
        } else {
            return firstIndexOfRecursiveHelper1(array, value, low, mid - 1, mid);
        }
    }

    // Recursive solution, version 2 - similar to iterative version 2.
    public static<V extends Comparable<? super V>> int firstIndexOfRecursive2(V[] array, V value) {
        return firstIndexOfRecursiveHelper2(array, value, 0, array.length - 1);
    }

    private static<V extends Comparable<? super V>> int firstIndexOfRecursiveHelper2(V[] array, V value, int low, int high) {
        if (low > high) {
            return -1;
        }
        int mid = (low + high) / 2;
        V midValue = array[mid];
        int cmp = value.compareTo(midValue);
        if (cmp > 0) {
            return firstIndexOfRecursiveHelper2(array, value, mid + 1, high);
        } else if (cmp < 0) {
            return firstIndexOfRecursiveHelper2(array, value, low, mid - 1);
        } else {
            int result = firstIndexOfRecursiveHelper2(array, value, low, mid - 1);
            if (result == -1) {
                return mid;
            } else {
                return result;
            }
        }
    }

    // Recursive solution, version 3 - using exception handling
    @SuppressWarnings("serial")
    public static class NotFound extends Exception {}

    public static<V extends Comparable<? super V>> int firstIndexOfRecursive3(V[] array, V value) {
        try {
            return firstIndexOfRecursiveHelper3(array, value, 0, array.length - 1);
        } catch (NotFound e) {
            return -1;
        }
    }

    private static<V extends Comparable<? super V>> int firstIndexOfRecursiveHelper3(V[] array, V value, int low, int high) throws NotFound {
        if (low > high) {
            throw new NotFound();
        }
        int mid = (low + high) / 2;
        V midValue = array[mid];
        int cmp = value.compareTo(midValue);
        if (cmp > 0) {
            return firstIndexOfRecursiveHelper3(array, value, mid + 1, high);
        }
        try {
            return firstIndexOfRecursiveHelper3(array, value, low, mid - 1);
        } catch (NotFound e) {
            if (cmp == 0) {
                return mid;
            } else {
                throw e;
            }
        }
    }


    // Recursive solution, version by student Salar Telo.
    // (https://git.chalmers.se/courses/data-structures/lp2/2024/lab-1/lab1-telo)
    public static<V extends Comparable<? super V>> int firstIndexOfRecursive4(V[] array, V value) {
        return firstIndexOfRecursiveHelper4(array, value, 0, array.length - 1);
    }

    private static<V extends Comparable<? super V>> int firstIndexOfRecursiveHelper4(V[] array, V value, int low, int high) {
        int index = findRecursiveHelper(array, value, low, high);
        if (index == -1) {
            return -1;
        } else if (index > 0 && value.equals(array[index - 1])) {
            return firstIndexOfRecursiveHelper4(array, value, low, index - 1);
        } else {
            return index;
        }
    }

    // This helper function can also be used by contains_recursive.
    private static<V extends Comparable<? super V>> int findRecursiveHelper(V[] array, V value, int low, int high) {
        if (low > high) {
            return -1;
        }
        int mid = (low + high) / 2;
        V midValue = array[mid];
        int cmp = value.compareTo(midValue);
        if (cmp > 0) {
            return findRecursiveHelper(array, value, mid + 1, high);
        } else if (cmp < 0) {
            return findRecursiveHelper(array, value, low, mid - 1);
        } else {
            return mid;
        }
    }

    //---------- END TASK 3 ---------------------------------------------------//

    // Put your own tests here.
    public static void main(String[] args) {
        Integer[] integerTestArray = {1, 3, 5, 7, 9};
        String[] stringTestArray = {"cat", "cat", "cat", "dog", "turtle", "turtle"};

        // Testing using assertions.
        // Remember to run with assertion checks turned on: `java -ea BinarySearch`
        assert containsIterative(integerTestArray, 4) == false;
        assert containsIterative(integerTestArray, 7) == true;

        assert containsRecursive(integerTestArray, 0) == false;
        assert containsRecursive(integerTestArray, 9) == true;

        assert firstIndexOf(stringTestArray, "cat") == 0;
        assert firstIndexOf(stringTestArray, "dog") == 3;
        assert firstIndexOf(stringTestArray, "turtle") == 4;
        assert firstIndexOf(stringTestArray, "zebra") == -1;

        // Or you can use printing.
        System.out.println("Is 5 in the array? " + containsIterative(integerTestArray, 5));
        System.out.println("Is 2 in the array? " + containsRecursive(integerTestArray, 2));
        System.out.println("First index of 'turtle': " + firstIndexOf(stringTestArray, "turtle"));
    }

}

