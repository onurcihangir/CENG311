import java.io.File;
import java.io.FileNotFoundException;
import java.util.Collections;
import java.util.PriorityQueue;
import java.util.Scanner;

public class MaxHeapPriQue {
	
	public static final int MAX_CAP = 16777216;

	public static void main(String[] args) throws FileNotFoundException {
		// TODO Auto-generated method stub

		PriorityQueue<Integer> pq = new PriorityQueue<Integer>(MAX_CAP,Collections.reverseOrder());
		Scanner scanner = new Scanner(new File("sayilar.txt"));
		long start = System.currentTimeMillis();
		while(scanner.hasNextInt()) {
			int num = scanner.nextInt();
			pq.add(num);
		}
		long end = System.currentTimeMillis();
		long seconds = (end-start);
		System.out.println("Number of integers: "+ MAX_CAP);
		System.out.println("Building queue in milliseconds: "+ seconds);
	}

}
