unit dluGenQuadSort;

{$mode Delphi}{$H+}

interface

uses dluGenSortBase
   , dluGenQuadSortBase;

type

{ TGenQuadSort }

 TGenQuadSort<_T> = class( TGenQuadSortBase<_T> )
   strict private
     var fMinRun    : integer;
         fRecursive : boolean;
     function LocateLinearFwd( const AElem: _T; const L, R: integer ): integer;  inline;
     function LocateLinearRvs( const AElem: _T; const L, R: integer ): integer;  inline;
     procedure MergeStd( const L, M, R: integer );
     procedure SubSortRecursive( const ALeft, ARight: integer );
     procedure SubSortIterate( const ALeft, ARight: integer );
     procedure SubSortStandard( const ALeft, ARight: integer );
   public
     constructor Create;
     constructor CreateRcs();
     procedure Sort( var AData: TuDataArray<_T>; ALess: TuLessFunc<_T> ); override;
end;

implementation

constructor TGenQuadSort<_T>.Create;
begin
   inherited Create;
   fRecursive   := false;
   fDescription := 'QuadItrSort';
end;

constructor TGenQuadSort<_T>.CreateRcs;
begin
   inherited Create;
   fRecursive   := true;
   fDescription := 'QuadRcsSort';
end;

function TGenQuadSort<_T>.LocateLinearFwd(const AElem: _T; const L, R: integer): integer;
begin
   Result  := L;
   while Result<=R do
      if fLessThen( AElem, fTable[Result] )
         then break
         else Inc( Result );
end;

function TGenQuadSort<_T>.LocateLinearRvs(const AElem: _T; const L, R: integer): integer;
begin
   Result  := R;
   if Result > L then
      while fLessThen( AElem, fTable[Result] ) do begin
         if Result > L then Dec( Result )
         else break;
      end;
end;

procedure TGenQuadSort<_T>.MergeStd(const L, M, R: integer);
  var i, j, k : integer;
      Lx, Rx  : integer;
begin
   if (L>M) or (M>R)
      then exit;

   if fLessThen( fTable[ M+1 ], fTable[ M ] ) then begin

      if fLessThen( fTable[ R ], fTable[ L ] ) then begin
         for i := L to R do fAux[i] := fTable[i];
         i := L;
         for k := M+1 to R do begin fTable[ i ] := fAux[ k ]; Inc( i );  end;
         for k := L   to M do begin fTable[ i ] := fAux[ k ]; Inc( i );  end;

      end else begin

         Lx := LocateLinearFwd( fTable[M+1], L,   M );
         Assert( Lx >= L );
         Rx := LocateLinearRvs( fTable[ M ], M+1, R );
         for k := Lx to Rx do fAux[k] := fTable[k];

         i := Lx;
         j := M + 1;
         k := Lx;

         while (i<=M) and (j<=Rx) do begin
            if fLessThen( fAux[j], fAux[i] ) then begin
               // Ai <= Bj
               fTable[k] := fAux[j];
               Inc(j);
            end else begin
               fTable[k] := fAux[i];
               Inc(i);
            end;
            Inc(k);
         end;

         while (i<=M ) do begin fTable[k] := fAux[i]; Inc(k); Inc(i); end;
         while (j<=Rx) do begin fTable[k] := fAux[j]; Inc(k); Inc(j); end;

         Assert( k = (Rx+1) );

      end;
   end;
end;

procedure TGenQuadSort<_T>.SubSortStandard(const ALeft, ARight: integer);
  var L, size, size2 : integer;
begin
   size := fMinRun;
   while size <= ARight do begin
      L     := ALeft;
      size2 := size shl 1;
      while (L+size) <= ARight do begin
         MergeStd( L, L + size - 1, Minimum( L + size2 - 1, ARight ) );
         Inc( L, size2 );
      end; {while}
      size := size2;
  end; {while}
end;

procedure TGenQuadSort<_T>.SubSortIterate(const ALeft, ARight: integer);
  var L, size: integer;
      size2, size4  : integer;
begin
   L := ALeft;
   //--------------------------------------------
   while (L + fMinRun) < ARight do begin
      InsertSort( L, L + fMinRun - 1 );
      Inc( L, fMinRun );
   end;
   InsertSort( L, ARight );
   //--------------------------------------------

   if fMinRun < ARight then begin
      SetLength( fAux, fRMaxIdx+1 );
      size := fMinRun;
      while size <= ARight do begin
         L     := ALeft;
         size2 := size shl 1;
         size4 := size shl 2;
         while (L + size4 - 1) <= ARight do begin
            MergeSrcToDst( fTable, fAux,   L,        L+size-1,       L+size2-1 );
            MergeSrcToDst( fTable, fAux,   L+size2,  L+size+size2-1, L+size4-1 );

            MergeSrcToDst( fAux,   fTable, L,        L+size2-1,      L+size4-1 );

            Inc( L, size4 );

         end;
         L     := size;
         size  := size4;
      end;

      SubSortStandard( L, ARight );
      MergeStd( ALeft, L-1, ARight );

   end; {if}

end;

procedure TGenQuadSort<_T>.SubSortRecursive(const ALeft, ARight: integer);
  var med2, med4 : integer;
begin

   if (ARight-ALeft) >= MIN_MERGE then begin
      med2 := (ARight-ALeft) div 2;
      med4 := med2 div 2;

      SubSortRecursive( ALeft,            ALeft + med4 );
      SubSortRecursive( ALeft + med4 + 1, ALeft + med2 );
      //-----------------------------v------v----------------v-------------
      MergeSrcToDst( fTable, fAux,   ALeft, ALeft + med4,    ALeft + med2 );

      SubSortRecursive( ALeft + med2 + 1,        ALeft + med2 + med4 );
      SubSortRecursive( ALeft + med2 + med4 + 1, ARight              );
      //-----------------------------v-----------------v---------------------v-------
      MergeSrcToDst( fTable, fAux,   ALeft + med2 + 1, ALeft + med2 + med4,  ARight );

      //========================================================================
      MergeSrcToDst( fAux,   fTable, ALeft,  ALeft + med2,  ARight );
      //========================================================================

   end else if (ARight-ALeft) >= 2 then begin

      InsertSort( ALeft, ARight );

   end;

end;

procedure TGenQuadSort<_T>.Sort(var AData: TuDataArray<_T>; ALess: TuLessFunc<_T>);
begin
   fTable    := AData;
   fLessThen := ALess;
   fRMaxIdx  := High( AData );

   if fRecursive then begin

      if (fRMaxIdx+1) >= MIN_MERGE then begin

         SetLength( fAux, fRMaxIdx+1 );
         SubSortRecursive( 0, fRMaxIdx );

      end else begin

         InsertSort( 0, fRMaxIdx );

      end;

   end else begin

      fMinRun   := MinRunLength( fRMaxIdx+1, MIN_MERGE );
      SubSortIterate( 0, fRMaxIdx );

   end;

end;

end.

