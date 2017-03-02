package DP;

import java.io.*;
import java.util.*;

/*
 * D[i][j] = 시작 지점에서 i행 j열로 올 때, 지나온 격자 칸에 적힌 수 합의 최대값

D[i][j] = max(D[i-1][j], D[i][j-1]) + A[i][j]

초기값: D[1][1] = A[1][1]

최종답: D[N][N]
 * 
 * */

public class 폐지줍기 {
	static int[][] D, A;
	
	public static void main(String[] args) throws Exception {
//      BufferedReader br = new BufferedReader(new InputStreamReader(System.in));
      BufferedReader br = new BufferedReader(new FileReader("C:\\input.txt"));
      
      int T = Integer.parseInt(br.readLine());
      for(int ts = 1; ts<=T; ts++){
    	  int N = Integer.parseInt(br.readLine());
    	  StringTokenizer st ;
    	  A = new int[N+1][N+1];
    	  // Input Value
    	  for(int i=1; i<=N; i++){
    		  st = new StringTokenizer(br.readLine());
    		  for(int j=1; j<=N; j++){
    			  A[i][j] = Integer.parseInt(st.nextToken());
    		  }
    	  }
    	  
    	  D = new int[N+1][N+1];
    	  for(int i=1; i<=N; i++){
    		  for(int j=1; j<=N; j++){
    			  if(i==1 && j==1) D[i][j] = A[i][j];
    			  if(i > 1)
    				  D[i][j] = Math.max(D[i][j], D[i-1][j] + A[i][j]);
    			  if(j > 1)
    				  D[i][j] = Math.max(D[i][j], D[i][j-1] + A[i][j]);
    		  }
    	  }
    	  
    	  System.out.println("#" + ts + " " + D[N][N]);
      }
      br.close();
  }
}
