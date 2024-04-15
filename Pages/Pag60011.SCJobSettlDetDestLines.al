#pragma implicitwith disable
page 60011 "SC Job Settl. Det. Dest. Lines"
{
    Caption = 'Podsumowanie';
    DeleteAllowed = false;
    Editable = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    PageType = ListPart;
    SourceTable = "SC Prod. Settl. Summary Lines";
    UsageCategory = None;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("OBIEKT Dim Value"; Rec."OBIEKT Dim Value")
                {
                    ApplicationArea = all;
                    Caption = 'Obiekt Koszt';
                }
                field("Job No."; Rec."Job No.")
                {
                    ApplicationArea = all;
                }
                field("Job Task No."; Rec."Job Task No.")
                {
                    ApplicationArea = all;
                }
                field("Job Planning Line No."; Rec."Job Planning Line No.")
                {
                    ApplicationArea = all;
                    HideValue = Rec."Job Planning Line No." = 0;
                }
                field("Work Type Code"; Rec."Work Type Code")
                {
                    ApplicationArea = all;
                    Editable = false;
                }
                field("Real Hours"; Rec."Real Hours")
                {
                    ApplicationArea = all;

                    trigger OnAssistEdit()
                    begin
                        LookupPage(Rec.FIELDNO("Real Hours"));
                    end;
                }
                field("Variable Amount To Post"; Rec."Variable Amount To Post")
                {
                    ApplicationArea = all;
                    Caption = 'Alokowane koszty';
                }
            }
        }
    }

    actions
    {
    }

    trigger OnAfterGetRecord()
    begin
        Rec.CALCFIELDS("Variable Cost Item");
        CalculateData;
    end;

    trigger OnOpenPage()
    begin
        Rec.SETCURRENTKEY("OBIEKT Dim Value", "Job Task No.", "Work Type Code");
    end;

    var
        ShowGLAccount: Boolean;
        TimeToConsum: Decimal;

    local procedure LookupPage(FieldNo: Integer)
    var
        CapacityLedgerEntry: Record "Capacity Ledger Entry";
        ProductionSettlementHeader: Record "SC Prod.Settlement Header";
        MachineCenter: Record "Machine Center";
        MCFilter: Text;
        TimeSheetLine: Record "Time Sheet Line";
        TimeSheetMgt: Codeunit "Time Sheet Management";
    begin
        ProductionSettlementHeader.GET(Rec."Document No.");

        TimeSheetLine.RESET;
        /// KPI Przenoszenie rozwiązania z projektu WEN "Settlement Cost"
        //TimeSheetLine.SETFILTER("Resource Group No.", "Resource Group Filter");
        TimeSheetLine.SETRANGE("Job No.", Rec."Job No.");
        TimeSheetLine.SETRANGE("Job Task No.", Rec."Job Task No.");
        /// KPI Przenoszenie rozwiązania z projektu WEN "Settlement Cost"
        //TimeSheetLine.SETRANGE("Job Planinng Line", Rec."Job Planning Line No.");
        TimeSheetLine.SETRANGE("Time Sheet Starting Date", ProductionSettlementHeader."Date From", ProductionSettlementHeader."Date To");
        TimeSheetLine.SETRANGE("Work Type Code", Rec."Work Type Code");

        /// KPI Przenoszenie rozwiązania z projektu WEN "Settlement Cost"
        //PAGE.RUN(PAGE::"JOF Time Sheet Lines", TimeSheetLine);
        Message('Funkcjonalność nie zaimplementowana. Aby zaimplementować funkcjonalność należy uruchomić pozostałe składniki rozliczania produykcji z firmy WEN');
    end;

    local procedure CalculateData()
    begin
        CLEAR(TimeToConsum);

        TimeToConsum := Rec.CalculateTimeToConsum;
    end;
}

#pragma implicitwith restore

