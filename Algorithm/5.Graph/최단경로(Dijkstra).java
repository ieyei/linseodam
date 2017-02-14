import java.io.*;
import java.util.*;

public class Solution {
    static int N, M, T;  
    static ArrayList<Integer>[] con, conv; // 경로, 가중치 
    static int[] D;// 최단경로 
    static int way1, way2, ans;
     
    public static void main(String args[]) throws Exception {
        BufferedReader br = new BufferedReader(new InputStreamReader(System.in));
//      BufferedReader br = new BufferedReader(new FileReader("C:\\input.txt"));
        
        T = Integer.parseInt(br.readLine());
        
        for(int ts = 1; ts<=T; ts++){
	        StringTokenizer st = new StringTokenizer(br.readLine());
	        N = Integer.parseInt(st.nextToken());
	        M = Integer.parseInt(st.nextToken());

	        // con[i] : i정점에 인접한 정점의 번호
	        // conv[i] : i정점에서 con[i]로 가는 간선 가중치 
	        con = new ArrayList[N+1];
	        conv = new ArrayList[N+1];
	        for (int i=1;i<=N;i++){
	            con[i] = new ArrayList<>();
	            conv[i] = new ArrayList<>(); // 가중치 
	        }
	        for (int i=1;i<=M;i++){
	            st = new StringTokenizer(br.readLine());
	            int a = Integer.parseInt(st.nextToken());
	            int b = Integer.parseInt(st.nextToken());
	            int c = Integer.parseInt(st.nextToken());
	            con[a].add(b); conv[a].add(c);
	            con[b].add(a); conv[b].add(c);
	        }
	 
	        D = new int[N+1]; // 시작점부터 해당 노드까지 최단 경로 
	        for (int i=1;i<=N;i++) 
	            D[i] = Integer.MAX_VALUE;
	         
	        // Binary Min Heap
	        // [0] : 거리 값, [1] : 정점번호 
	        PriorityQueue<int[]> que = new PriorityQueue<>(10, new Comparator<int[]>() {
	            public int compare(int[] a, int[] b) {
	                return a[0] - b[0];
	            }
	        });
	         
	        D[1] = 0; 
	        que.add(new int[]{0,1});
	         
	        while (!que.isEmpty()){
	            int q = que.peek()[1]; // 정점 번호
	            int d = que.peek()[0]; // 거리 값
	            que.poll();
	            
	            if (D[q] != d) continue;	// q정점 이전에 처리 OR 갱신
	            for (int i=0;i<con[q].size();i++){
	                int t = con[q].get(i); 	// 인접한 정점 번호
	                int v = conv[q].get(i);	// q -> t 간선 가중치 
	                if (D[t] > D[q] + v){
	                    D[t] = D[q] + v;
	                    que.add(new int[]{D[t], t});
	                }
	            }
	        }
	        
	        System.out.println("#" + ts + " " + (D[N] < Integer.MAX_VALUE ? D[N] : -1));
        }
    }
}
