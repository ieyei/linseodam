import java.io.*;
import java.util.*;

public class 최저공통조상 {
	static int N, Q, T;
	static int[][] par;
	static ArrayList<Integer>[] con ;
	static int[] dep;

	public static void main(String[] args)throws Exception {
//		BufferedReader br = new BufferedReader(new InputStreamReader(System.in));
      BufferedReader br = new BufferedReader(new FileReader("C:\\input.txt"));
      BufferedWriter bw = new BufferedWriter(new OutputStreamWriter(System.out));
		
		T = Integer.parseInt(br.readLine());	// 1 ≤ T ≤ 15
		
		for(int ts=1; ts<=T; ts++){
	        StringTokenizer st = new StringTokenizer(br.readLine());
	        N = Integer.parseInt(st.nextToken());	// 정점 1 ≤ N, Q ≤ 100,000
	        Q = Integer.parseInt(st.nextToken());	// 질의
	        
	        par = new int[N+1][17];
	        con = new ArrayList[N+1];
	        for(int i=1; i<=N; i++)	
	        	con[i] = new ArrayList<>();
	        
	        st = new StringTokenizer(br.readLine());
	        for(int i=2; i<=N; i++){
	        	par[i][0] = Integer.parseInt(st.nextToken());
	        	con[par[i][0]].add(i);
	        }
	        
	        for (int i=1;i<17;i++) for (int j=1;j<=N;j++)
	        	par[j][i] = par[par[j][i-1]][i-1];
	
	        // 정점 깊이 계산
	        dep = new int[N+1];
	        Queue<Integer> que = new LinkedList<>();
	        que.add(1);
	        while (!que.isEmpty()){
	        	int q = que.poll();
	        	for (int t: con[q]){
	        		dep[t] = dep[q]+1;
	        		que.add(t);
	        	}
	        }
	        
	        bw = new BufferedWriter(new OutputStreamWriter(System.out));
	        bw.write("#" + ts);
	        for (int i=1;i<=Q;i++){
	        	st = new StringTokenizer(br.readLine());
	        	int a = Integer.parseInt(st.nextToken());	// 1 ≤ a, b ≤ N
	        	int b = Integer.parseInt(st.nextToken());
	        	bw.write(" " + lca(a, b));
	        }
	        bw.write("\n");
//	        bw.close();
	        bw.flush();
		}
	}
	
	static int lca(int a, int b) {
		// 1. a번 정점의 깊이가 b번 정점의 깊이보다 얕지 않다고 가정
		if (dep[a] < dep[b]){
			/* XOR swap algorithm */
			a ^= b; b ^= a; a ^= b;
		}
		// 2. a번 정점의 깊이가 b번 정점의 깊이와 같아지도록 a번 정점을 위로 올린다
		//		이 때, a번 정점을 위로 올려도 lca(a, b)는 변하지 않는다!
		for (int i=0;i<17;i++) if (((1 << i) & (dep[a] - dep[b])) != 0)
			a = par[a][i];
		// 3. 만약 a = b라면, lca(a, b) = a
		if (a == b) return a;
		// 4. a번 정점과 b번 정점이 같지 않을 때까지 위로 올린다
		for (int i=17;i-->0;) if (par[a][i] != par[b][i]){
			a = par[a][i]; b = par[b][i];
		}
		// 5. lca(a, b) = parent[a][0]
		return par[a][0];
	}

}
