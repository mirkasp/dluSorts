unit dluGenSortBase;

{$mode Delphi}{$H+}

interface

type TuLogProc = procedure( const AText: string ) of object;

type TuDataArray<_T> = array of _T;
type TuLessFunc<_T>  = function( const Item1, Item2: _T ): boolean;
type TuPrintItem<_T> = function( const AItem: _T ): string;

type IuSorter<_K> = interface
   procedure Sort( var AData: TuDataArray<_K>; ALess: TuLessFunc<_K> );
   function GetLogProc: TuLogProc;
   procedure SetLogProc(AValue: TuLogProc);
   function SorterInfo(): string;
   property OnLogProc: TuLogProc read GetLogProc write SetlogProc;
end;

function MinRunLength( const N, MinMerge: integer ): integer; inline;
function Minimum( const X, Y: integer ): integer; inline;

type

{ TGenSortBase }

 TGenSortBase<_K> = class( TInterfacedObject, IuSorter<_K> )
   strict private
      fLogProc  : TuLogProc;
      function GetLogProc: TuLogProc;
      procedure SetLogProc(AValue: TuLogProc);
   protected
      fDescription : string;
      procedure Log( const AText: string ); dynamic; overload;
      procedure Log( const AFormat: string; AParam: array of const ); dynamic; overload;
   public
      class function IsSorted( const AData: TuDataArray<_K>; ALess: TuLessFunc<_K> ): boolean;
      //
      procedure Sort( var AData: TuDataArray<_K>; ALess: TuLessFunc<_K> ); virtual; abstract;
      function SorterInfo(): string; virtual;
end;


implementation

uses SysUtils
   , TypInfo
   ;

function MinRunLength( const N, MinMerge: integer ): integer;
  var r : integer = 0;
begin
   // Minrun is chosen from the range 32 to 64 inclusive,
   // such that the size of the data, divided by minrun,
   // is equal to, or slightly less than, a power of two.
   // The final algorithm takes the six most significant
   // bits of the size of the array, adds one if any of
   // the remaining bits are set, and uses that result as the minrun.
   // This algorithm works for all arrays, including those smaller
   // than 64; for arrays of size 63 or less, this sets minrun equal
   // to the array size and Timsort reduces to an insertion sort.

   Assert( N >= 0 );
   Result := N;
   // Becomes 1 if any 1 bits are shifted off
   while (Result >= MinMerge) do begin
       r := r or (Result and 1);
       Result := Result shr 1;
   end;
   Result := Result + r;
end;

function Minimum( const X, Y: integer ): integer;
begin
   if X < Y then Result := X else Result := Y;
end;

{ TCustomSort }

class function TGenSortBase<_K>.IsSorted(const AData: TuDataArray<_K>; ALess: TuLessFunc<_K>): boolean;
  var i: integer;
begin
   Result := Length( AData ) > 0;
   for i := 1 to High( AData ) do
     if ALess( AData[i], AData[i-1] ) then begin
        Result := false;
        break;
     end;
end;

function TGenSortBase<_K>.GetLogProc: TuLogProc;
begin
   Result := fLogProc;
end;

procedure TGenSortBase<_K>.SetLogProc(AValue: TuLogProc);
begin
   fLogProc := AValue;
end;

procedure TGenSortBase<_K>.Log(const AText: string);
begin
   if Assigned( fLogProc ) then fLogProc( AText );
end;

procedure TGenSortBase<_K>.Log(const AFormat: string; AParam: array of const);
begin
   if Assigned( fLogProc ) then fLogProc( Format( AFormat, AParam ) );
end;

function TGenSortBase<_K>.SorterInfo: string;
begin
   Result := fDescription + '<' + PTypeInfo( TypeInfo(_K) )^.Name + '>';
end;

end.

