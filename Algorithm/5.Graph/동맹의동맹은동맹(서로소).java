import java.io.*;
import java.util.*;
 
// 서로소 집합 (Disjoint Set)
// Union, Find, 경로압축 
// 1번 사람, 3번 사람 동맹 맺음 => union(1,3)
// 1번 사람, 7번 사람 동맹 관계? => find(1) = find(7) ? 
public class Solution {
    static int[] par;
    static int T,N,Q;
 
    public static void main(String[] args) throws Exception {
      BufferedReader br = new BufferedReader(new InputStreamReader(System.in));
//      BufferedReader br = new BufferedReader(new FileReader("C:\\input.txt"));
      BufferedWriter bw = new BufferedWriter(new OutputStreamWriter(System.out));
      
      T = Integer.parseInt(br.readLine());
      
      for(int ts = 1; ts<=T; ts++){
	      N = Integer.parseInt(br.readLine());
	      par = new int[N+1];
	      for (int i=1;i<=N;i++) par[i] = i; 
	       
	      int ans = 0;
	      Q = Integer.parseInt(br.readLine());
	      while (Q-- > 0){
	        StringTokenizer st = new StringTokenizer(br.readLine());
	        int t = Integer.parseInt(st.nextToken());
	        int a = Integer.parseInt(st.nextToken());
	        int b = Integer.parseInt(st.nextToken());
	        if (t == 0){
	            union(a, b);
	        }else{
	            if (find(a) == find(b)) {
	            	ans ++ ;
	            }
	        }
	      }
	      
	      bw.write("#" + ts + " " + ans);
	      bw.newLine();
          bw.flush();
          
	    }
      br.close();
      bw.close();
    }
     
    static int find(int n) { // 경로 압축 
        if (par[n] == n) return n;
        return par[n] = find(par[n]); 
    }
 
     
    static void union(int a, int b) {
        int p = find(a), q = find(b);
        if (p == q) return;
        par[q] = p;
    }   
    
}
