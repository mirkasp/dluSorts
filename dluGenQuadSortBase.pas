unit dluGenQuadSortBase;

{$mode Delphi}{$H+}

interface

uses dluGenSortBase;

type

{ TGenQuadSortBase }

 TGenQuadSortBase<_T> = class( TGenSortBase<_T> )
   protected
      const MIN_MERGE = 64;
      var fTable   : TuDataArray<_T>;
          fAux     : TuDataArray<_T>;
          fLessThen: TuLessFunc<_T>;
          //
          fTemp    : _T;
          fRMaxIdx : integer;
      procedure InsertSort( const ALeft, ARight: integer ); inline;
      procedure MergeSrcToDst( var Src, Dst: TuDataArray<_T>; const L, M, R: integer );
end;

implementation

{ TGenQuadSortBase }

procedure TGenQuadSortBase<_T>.InsertSort(const ALeft, ARight: integer);
  var i, j : integer;
begin
   for i := ALeft+1 to ARight do begin
      if fLessThen( fTable[ i ], fTable[ i-1 ] ) then begin
         fTemp := fTable[ i ];
         j     := Pred(i);
         repeat
            fTable[ j+1 ] := fTable[ j ];
            Dec( j );
         until (j<ALeft) or not fLessThen( fTemp, fTable[ j ] );
         fTable[ j+1 ] := fTemp;
      end;
   end;
end;

procedure TGenQuadSortBase<_T>.MergeSrcToDst(var Src, Dst: TuDataArray<_T>; const L, M, R: integer);
  var i, j, k: integer;
begin
   if not fLessThen( Src[ M+1 ], Src[ M ] ) then begin
      // A[m] <= A[m+1]
      for i := L to R do Dst[i] := Src[i];

   end else if fLessThen( Src[ R ], Src[ L ] ) then begin
      // A[R] < A[L]
      i := L;
      for k := M+1 to R do begin Dst[ i ] := Src[ k ]; Inc( i );  end;
      for k := L   to M do begin Dst[ i ] := Src[ k ]; Inc( i );  end;

   end else begin
      i := L;
      j := M + 1;
      k := L;

      while (i<=M) and (j<=R) do begin
         if fLessThen( Src[ j ], Src[ i ] ) then begin
            // Ai <= Bj
            Dst[ k ] := Src[ j ]; Inc( j );
         end else begin
            // Ai > Bj
            Dst[ k ] := Src[ i ]; Inc( i );
         end;
         Inc( k );
      end;

      while (i<=M) do begin Dst[ k ] := Src[ i ]; Inc( k ); Inc( i ); end;
      while (j<=R) do begin Dst[ k ] := Src[ j ]; Inc( k ); Inc( j ); end;

      Assert( k = (R+1) );

   end;

end;


end.

