#include <stdio.h>
#include <stdlib.h>
#include <time.h>

#define NUM 16777216 // 2^24

FILE *fptr;

typedef struct node {
    int data;
    struct node *left;
    struct node *right;
} node;

void queue(int, int *, int *);

void swap(int *, int *);

node *convert(int *, int, int);

node *newNode(int);

void printBreadthFirst(node *root);

void printCurrentLevel(node *, int);

int height(node *);

int parent(int);

int main() {
    // I used the code in the comment below to create an integer file.

    /*FILE *wPtr;
    wPtr = fopen("sayilar.txt", "w");

    srand(time(NULL));   // Initialization, should only be called once.
    for (int k = 0; k < NUM; ++k) {
        int r = rand() % 50;
        fprintf(wPtr, "%d ", r);
    }

    fclose(wPtr);*/

    int *numberArray = (int*)malloc(NUM * sizeof(int));
    int *pri_que = (int*)malloc(NUM * sizeof(int));
    int currentSize = -1;
    int *pSize = &currentSize;

    FILE *myFile;
    myFile = fopen("sayilar.txt", "r");

    if (myFile == NULL) {
        printf("Error Reading File\n");
        exit(0);
    }

    for (int i = 0; i < NUM; i++) {
        fscanf(myFile, "%d ", &numberArray[i]);
    }

    fclose(myFile);

    printf("Number of integers: %d\n", NUM);

    clock_t t;
    t = clock();

    for (int j = 0; j < NUM; ++j) {
        queue(numberArray[j], pri_que, pSize);
    }

    t = clock() - t;
    double time_taken = ((double)t)/CLOCKS_PER_SEC;
    printf("Building queue took %f seconds to execute.\n", time_taken);

    node *root = convert(pri_que, 0, NUM-1);

    // created a file to write priority queue in it.
    fptr = fopen("integers.txt", "w");

    if (fptr != NULL) {
        printf("File created successfully!\n");
    }
    else {
        printf("Failed to create the file.\n");
        // exit status for OS that an error occurred
        return -1;
    }

    // print result to the output file.
    printBreadthFirst(root);

    // close connection
    fclose(fptr);

    return 0;
}

//Function to insert new data to priority queue
void queue(int data, int *pri_que, int *pSize) {
    if (*pSize == NUM) {
        printf("Overflow");
        return;
    }
    //number of integers in priority queue increased.
    *pSize += 1;
    int i = *pSize;
    //add data to end of queue.
    pri_que[i] = data;
    while (i > 0 && pri_que[parent(i)] < pri_que[i]) {
        //if data is bigger than parent node, swap nodes.
        swap(&pri_que[i], &pri_que[parent(i)]);
        i = parent(i);
    }
}

void swap(int *x, int *y) {
    int temp = *x;
    *x = *y;
    *y = temp;
}

// Function that constructs heapify structure from an array
node *convert(int *arr, int start, int end) {
    if (start > end)
        return NULL;

    //get the first element and make it root
    int first = start;
    node *root = newNode(arr[first]);

    //recursively assign left child of node
    int left = (2 * first) + 1;
    root->left = convert(arr, left, end);

    //recursively assign right child of node
    int right = (2 * first) + 2;
    root->right = convert(arr, right, end);

    return root;
}

//Function that creates a new node with the
//given data and null left and right pointers.
node *newNode(int data) {
    node *new = malloc(sizeof(node));
    new->data = data;
    new->left = NULL;
    new->right = NULL;

    return new;
}

//Function to print breadth-first traversal
void printBreadthFirst(node *root) {
    int h = height(root);
    int i;
    for (i = 1; i <= h; i++)
        printCurrentLevel(root, i);
}

//Print nodes at a current level
void printCurrentLevel(node *root, int level) {
    if (root == NULL)
        return;
    if (level == 1) {
        fprintf(fptr, "%d ", root->data);
    }
    else if (level > 1) {
        printCurrentLevel(root->left, level - 1);
        printCurrentLevel(root->right, level - 1);
    }
}

//Compute the "height" of a tree
int height(node *node) {
    if (node == NULL)
        return 0;
    else {
        //compute the height of each subtree
        int lheight = height(node->left);
        int rheight = height(node->right);

        //use the larger one
        if (lheight > rheight)
            return (lheight + 1);
        else
            return (rheight + 1);
    }
}

// Function to return the index of the
// parent node of a given node
int parent(int i)
{
    return (i - 1) / 2;
}