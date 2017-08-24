unit dStringGridHelper;

interface

uses

  FireDAC.Comp.Client, Data.Bind.Components, Data.Bind.Grid, System.Classes,
  Data.DB, Data.Bind.DBScope, VCL.Grids;

type

  TStringGridHelper = class helper for TStringGrid
  private
    function FindBindComp(const ABindingsList: TBindingsList; const AGridName: String): TLinkGridToDataSource;
    function FindMember(const ALinkGridToDataSource: TLinkGridToDataSource; const AHeaderName: String): String;
  public
    procedure SortRecords(const BindingsList: TBindingsList; const HeaderName: String);
  end;


implementation

{ TStringGridHelper }

{ Given a binding list and a String Grid component name, this routine returns the
  TLinkGridToDataSource object that contains information about the binding to the grid }

function TStringGridHelper.FindBindComp(const ABindingsList: TBindingsList; const AGridName: String): TLinkGridToDataSource;
var
  I: Integer;                                                                  // Index
begin
  Result := nil;                                                               // Default "not found"
  for I := 0 to pred(ABindingsList.BindCompCount) do                           // loop through all binding components in the list
    begin
      if ABindingsList.BindComps[I] is TLinkGridToDataSource then              // must be a link grid to datasource
        begin
          if ABindingsList.BindComps[I].ControlComponent.Name = AGridName then // check for the specified grid name
            Exit(TLinkGridToDataSource(ABindingsList.BindComps[I]));           // if found, return the binding list entry
        end;
    end;
end;

{ Given a binding list component and header name (the text in the header of the column), return
  the Member Name that populates the column. This will be the field name in the underlying dataset.

  Notes: Often, Headername and MemberName are the same. This occurs if no HeaderName has been specified for the link.
  This routine accepts null values for the Link. Thus if the request to find the link failed (and returned nil)
  this routine will simply return the provided HeaderName.

  Note: It is possible to specify duplicate HeaderNames, e.g., two columns with the same header text. The first HeaderName
    that matches will be the one selected. Order is determined by the order they appear in the Columns collection. Duplicate
    names can only occur when HeaderNames are manually specified. They ordinarily default to the MemberName, which is the column name,
    and will hence be unique. }

function TStringGridHelper.FindMember(const ALinkGridToDataSource: TLinkGridToDataSource; const AHeaderName: String): String;
var
  I: Integer;                                                                 // Index
begin
  Result := AHeaderName;                                                      // default return value if no membername found
  if Assigned(ALinkGridToDataSource) then                                     // bypass if no valid link
    begin
      for I := 0 to pred(ALinkGridToDataSource.Columns.Count) do              // search through the link columns
        begin
          if ALinkGridToDataSource.Columns.Items[I].Header = AHeaderName then // test for HeaderName match
            begin
              Exit(ALinkGridToDataSource.Columns.Items[I].MemberName);        // if matched return the related MemberName (dataset field)
            end;
        end;
    end;
end;

{ This is the single entry point for this helper. It most easily invoked from the OnFixedCellClick event of the TStringGrid that
  requires a column sort. Example:

  procedure TfSObjDisplay.GridSort(Sender: TObject; ACol, ARow: Integer);
  begin
  TStringGrid(Sender).SortRecords(BindingsList1, TStringGrid(Sender).Cells[ACol, ARow]);
  end;

  Also note that the properties of the TString grid should specify
    goColMoving = False (I know of no way to have both column moving and Fixed Column click recognition)
    goFixedColClick = True   Not sure why both of these need to be chosen as True
    goFixedRowClick = True   but was unable to get the OnFixedCellClick event to fire unless they were both set to True

}

procedure TStringGridHelper.SortRecords(const BindingsList: TBindingsList; const HeaderName: String);
var
  LLinkGridToDataSource: TLinkGridToDataSource;                           // Bindingslist link component for the TStringGrid
  LBindSourceDB: TBindSourceDB;                                           // BindSourceDB component that actually points to related table
  LQuery: TFDQuery;                                                       // The underlying FDQuery that supplies data to the TStringGrid
  LMemberName: String;                                                    // The FDQuery column name that supplies data to the column
begin
  LLinkGridToDataSource := FindBindComp(BindingsList, Self.Name);         // discover the grid <==> datasource object
  Assert(LLinkGridToDataSource.DataSource is TBindSourceDB, 'Datasource must be TBindSourceDB.'); // verify object type
  LBindSourceDB := TBindSourceDB(LLinkGridToDataSource.DataSource);       // discover the binding database object
  Assert(LBindSourceDB.DataSet is TFDQuery, 'DataSet must be TFDQuery.'); // verify the object type
  LQuery := TFDQuery(LBindSourceDB.DataSet);                              // discover the underlying FDQuery
  LMemberName := FindMember(LLinkGridToDataSource, HeaderName);           // extract the column name for the desired sort
  LLinkGridToDataSource.Active := False;                                  // disable the binding
  LQuery.IndexFieldNames := LMemberName;                                  // apply the column name to the IndexFieldNames property
  LQuery.IndexesActive := True;                                           // make sure the indexes are active
  LLinkGridToDataSource.Active := True;                                   // enable the binding
end;

end.
