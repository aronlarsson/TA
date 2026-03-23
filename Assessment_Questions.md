# Lab 1

- Why do you set high to array.length - 1 / array.length?
    - High is inclusive, so array.length - 1 is the last element in the array.
    - or
    - High is exclusive, and array.length is the first index outside the array.

- Why do you have low <= high / low < high as the loop guard in the while loop?
    - High is inclusive, so as long as low is <= high it is searching within the correct bounds. If low > high, it has moved outside the search range, and couldn't find any match.
    - or
    - High is exclusive, so if low is >= high, it has moved outside the search range, which means it couldn't find any match.

- What happens when low == high?
    - High is inclusive, so it might be the case that the value we are searching for is located at index high, which means that the value will be found at that index. If the value doesn't exist, it will try to move either high or low past the other, which means the value could not be found.
    - or
    - High is exclusive, which means that if low moved to high it has moved outside the search range, so the loop/recursion will break and return something indicating that the value wasn't found.