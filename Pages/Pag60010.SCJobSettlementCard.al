#pragma implicitwith disable
page 60010 "SC Job Settlement Card"
{
    Caption = 'Rozliczenie zleceń';
    DataCaptionFields = "No.";
    DelayedInsert = true;
    InsertAllowed = false;
    SourceTable = "SC Prod.Settlement Header";
    UsageCategory = None;

    layout
    {
        area(content)
        {
            group(General)
            {
                Caption = 'Ogólne';
                field("No."; Rec."No.")
                {
                    ApplicationArea = all;
                    Editable = false;
                }
                field("Settlement Type"; Rec."Settlement Type")
                {
                    ApplicationArea = all;
                    Editable = false;
                }
                field(Status; Rec.Status)
                {
                    ApplicationArea = all;
                    Editable = false;
                }
                field("Document Date"; Rec."Document Date")
                {
                    ApplicationArea = all;
                    Editable = false;
                }
                field("User Name"; Rec."User Name")
                {
                    ApplicationArea = all;
                    Editable = false;
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = all;
                    Description = '003.168';
                }
                field("Account No. (6*)"; Rec."Account No. (6*)")
                {
                    ApplicationArea = all;
                    Description = '003.168';
                }
                field("Account No. (4*)"; Rec."Account No. (4*)")
                {
                    ApplicationArea = all;
                    Description = '003.168';
                }
                field("Account No. (7*)"; Rec."Account No. (7*)")
                {
                    ApplicationArea = all;
                    Description = '003.168';
                }
            }
            group(Filters)
            {
                Caption = 'Filtry';
                field(Month; Rec.Month)
                {
                    ApplicationArea = all;
                    Editable = EditableDate;
                    ShowMandatory = true;

                    trigger OnValidate()
                    begin
                        // <-- 003.125 LKA 20200407
                        EditableDate := Rec.CheckDate(Rec."Date From");
                        // --> 003.125
                    end;
                }
                field(Year; Rec.Year)
                {
                    ApplicationArea = all;
                    Editable = EditableDate;
                    ShowMandatory = true;

                    trigger OnValidate()
                    begin
                        // <-- 003.125 LKA 20200407
                        EditableDate := Rec.CheckDate(Rec."Date From");
                        // --> 003.125
                    end;
                }
                field("Date From"; Rec."Date From")
                {
                    ApplicationArea = all;
                    Editable = false;
                }
                field("Date To"; Rec."Date To")
                {
                    ApplicationArea = all;
                    Editable = false;
                }
                field("PROJEKT Dim Filter"; Rec."PROJEKT Dim Filter")
                {
                    ApplicationArea = all;
                }
                field("G/L Account Filter"; Rec."G/L Account Filter")
                {
                    ApplicationArea = all;
                }
                field("MKP Dim Filter"; Rec."MKP Dim Filter")
                {
                    ApplicationArea = all;
                }
                field("KALKULACJA Dim Filter"; Rec."KALKULACJA Dim Filter")
                {
                    ApplicationArea = all;
                }
                field("Fixed Costs Dim Value"; Rec."Fixed Costs Dim Value")
                {
                    ApplicationArea = all;
                }
                field("Variable Costs Dim Value"; Rec."Variable Costs Dim Value")
                {
                    ApplicationArea = all;
                }
                field("Work Type Code Filter"; Rec."Work Type Code Filter")
                {
                    ApplicationArea = all;
                }
            }
            part("Job Settl. Subform Sum Lines"; "SC Settl. Subform Sum Lines")
            {
                SubPageLink = "Document No." = field("No.");
                SubPageView = WHERE("Line Type" = CONST("General Sum"));
                ApplicationArea = all;
            }
        }
    }

    actions
    {
        area(processing)
        {
            action("Process Lines")
            {
                ApplicationArea = all;
                Caption = 'Wygeneruj';
                Image = CalculateLines;

                trigger OnAction()
                var
                    ProcessJobSettlement: Report "SC Process Job Settlement";
                    ProductionSettlementHeader: Record "SC Prod.Settlement Header";
                    GLEntry: Record "G/L Entry";
                    CapacityLedgerEntry: Record "Capacity Ledger Entry";
                begin
                    Rec.TESTFIELD("Date From");
                    Rec.TESTFIELD("Date To");
                    Rec.TESTFIELD("KALKULACJA Dim Filter");
                    Rec.TESTFIELD("Fixed Costs Dim Value");
                    Rec.TESTFIELD("Variable Costs Dim Value");
                    Rec.TESTFIELD("PROJEKT Dim Filter");

                    ProductionSettlementHeader.RESET;
                    ProductionSettlementHeader.SETRANGE("No.", Rec."No.");
                    ProcessJobSettlement.SETTABLEVIEW(ProductionSettlementHeader);

                    GLEntry.RESET;
                    GLEntry.SETFILTER("G/L Account No.", Rec."G/L Account Filter");
                    GLEntry.SETRANGE("Posting Date", Rec."Date From", Rec."Date To");
                    ProcessJobSettlement.SETTABLEVIEW(GLEntry);

                    ProcessJobSettlement.RUNMODAL;
                    //CalcAlocation;
                    CurrPage.UPDATE(FALSE);
                end;
            }
            action("Oblicz alokację kosztów")
            {
                ApplicationArea = all;
                Caption = 'Oblicz alokację kosztów';
                Image = Recalculate;

                trigger OnAction()
                var
                    ProdSettlSummaryLines: Record "SC Prod. Settl. Summary Lines";
                begin
                    CalcAlocation;
                    MESSAGE('Alokacja kosztów została obliczona');
                end;
            }
            action("Generate Gen. Jnl. Journal")
            {
                ApplicationArea = all;
                Caption = 'Wygeneruj dzien. K/G zleceń';
                Image = OutputJournal;

                trigger OnAction()
                var
                    ProdSettlSummaryLines: Record "SC Prod. Settl. Summary Lines";
                    JobGenJnlLines: Report "SC Job Gen. Jnl. Lines";
                begin
                    ProdSettlSummaryLines.RESET;
                    ProdSettlSummaryLines.SETRANGE("Document No.", Rec."No.");
                    JobGenJnlLines.SETTABLEVIEW(ProdSettlSummaryLines);
                    JobGenJnlLines.RUNMODAL;
                end;
            }

            action(New)
            {
                ApplicationArea = all;
                Caption = 'Nowe';
                Description = '003.168';
                Image = NewDocument;

                trigger OnAction()
                var
                    ProductionSettlementDialog: Page "SC Production Settl. Dialog";
                    ProductionSettlementCard: Page "SC Production Settlement Card";
                    AssemblySettlementCard: Page "SC Assembly Settlement Card";
                    JobSettlementCard: Page "SC Job Settlement Card";
                    ProductionSettlementHeader: Record "SC Prod.Settlement Header";
                begin
                    ProductionSettlementDialog.LOOKUPMODE := TRUE;
                    ProductionSettlementDialog.InitPage(Rec, Rec."Settlement Type"::Job);
                    IF ProductionSettlementDialog.RUNMODAL IN [ACTION::LookupOK, ACTION::OK] THEN BEGIN
                        ProductionSettlementDialog.GetRec(ProductionSettlementHeader);
                        JobSettlementCard.SETRECORD(ProductionSettlementHeader);
                        JobSettlementCard.RUN;
                    END;
                end;
            }

            action("Generate Journal")
            {
                ApplicationArea = all;
                Caption = 'Wygeneruj wiersze dziennika';
                Image = GeneralPostingSetup;

                trigger OnAction()
                var
                    ProductionSettlementHeader: Record "SC Prod.Settlement Header";
                    GenerateGenJournal: Report "SC Generate Gen. Journal";
                begin
                    CurrPage.SETSELECTIONFILTER(ProductionSettlementHeader);
                    GenerateGenJournal.SETTABLEVIEW(ProductionSettlementHeader);
                    GenerateGenJournal.RUN;
                end;
            }
        }
    }

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        Rec."Document Date" := TODAY;
        Rec."User Name" := USERID;

        Rec."Settlement Type" := Rec."Settlement Type"::Job;
        Rec."PROJEKT Dim Filter" := '0000*';
    end;

    trigger OnOpenPage()
    begin
        // <-- 003.125 LKA 20200407
        EditableDate := Rec.CheckDate(Rec."Date From");
        // --> 003.125

        // <-- 003.168 LKA 20200806
        Rec.FILTERGROUP(2);
        Rec.SETRANGE("Settlement Type", Rec."Settlement Type"::Job);
        // --> 003.168
    end;

    trigger OnQueryClosePage(CloseAction: Action): Boolean
    begin
        IF CloseAction = ACTION::No THEN
            MESSAGE('Anulowano!');
    end;

    var
        "_003.125_": Integer;

        EditableDate: Boolean;

    local procedure CalcAlocation()
    var
        ProdSettlSummaryLines: Record "SC Prod. Settl. Summary Lines";
    begin
        ProdSettlSummaryLines.RESET;
        ProdSettlSummaryLines.SETRANGE("Document No.", Rec."No.");
        ProdSettlSummaryLines.SETRANGE("Line Type", ProdSettlSummaryLines."Line Type"::"General Sum");
        ProdSettlSummaryLines.FINDFIRST;
        ProdSettlSummaryLines.CalculateJobTime;
        CurrPage.UPDATE(FALSE);
    end;
}

#pragma implicitwith restore

