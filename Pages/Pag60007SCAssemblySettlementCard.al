#pragma implicitwith disable
page 60007 "SC Assembly Settlement Card"
{
    Caption = 'Rozliczenie kompletacji';
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
                field("Fixed Cost Item"; Rec."Fixed Cost Item")
                {
                    ApplicationArea = all;
                }
                field("Variable Cost Item"; Rec."Variable Cost Item")
                {
                    ApplicationArea = all;
                }
            }
            part("Asb. Settl. Subform Sum Lines"; "SC Asb. Settl. Subform Sum Lin")
            {
                SubPageLink = "Document No." = FIELD("No.");
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
                    ProcessProductionSettlement: Report "SC Process Prod. Settlement";
                    ProductionSettlementHeader: Record "SC Prod.Settlement Header";
                    GLEntry: Record "G/L Entry";
                    CapacityLedgerEntry: Record "Capacity Ledger Entry";
                begin
                    Rec.TESTFIELD("Date From");
                    Rec.TESTFIELD("Date To");
                    Rec.TESTFIELD("KALKULACJA Dim Filter");
                    Rec.TESTFIELD("Fixed Costs Dim Value");
                    Rec.TESTFIELD("Variable Costs Dim Value");

                    ProductionSettlementHeader.RESET;
                    ProductionSettlementHeader.SETRANGE("No.", Rec."No.");
                    ProcessProductionSettlement.SETTABLEVIEW(ProductionSettlementHeader);

                    GLEntry.RESET;
                    GLEntry.SETFILTER("G/L Account No.", Rec."G/L Account Filter");
                    GLEntry.SETRANGE("Posting Date", Rec."Date From", Rec."Date To");
                    ProcessProductionSettlement.SETTABLEVIEW(GLEntry);

                    CapacityLedgerEntry.RESET;
                    CapacityLedgerEntry.SETRANGE("Posting Date", Rec."Date From", Rec."Date To");
                    CASE Rec."Settlement Type" OF
                        Rec."Settlement Type"::Production:
                            CapacityLedgerEntry.SETRANGE("Order Type", CapacityLedgerEntry."Order Type"::Production);
                        Rec."Settlement Type"::Assembly:
                            CapacityLedgerEntry.SETRANGE("Order Type", CapacityLedgerEntry."Order Type"::Assembly);
                    END;
                    ProcessProductionSettlement.SETTABLEVIEW(CapacityLedgerEntry);

                    ProcessProductionSettlement.RUNMODAL;
                    CalcAlocation;
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
            action("Generate Revaluation Journal")
            {
                ApplicationArea = all;
                Caption = 'Wygeneruj dzien. przeszacowań';
                Image = OutputJournal;

                trigger OnAction()
                var
                    ProdSettlSummaryLines: Record "SC Prod. Settl. Summary Lines";
                    AsbSettlRevaluationLines: Report "SC Asb. Settl. Revaluation Lin";
                begin
                    Commit();
                    ProdSettlSummaryLines.RESET;
                    ProdSettlSummaryLines.SETRANGE("Document No.", Rec."No.");
                    AsbSettlRevaluationLines.SETTABLEVIEW(ProdSettlSummaryLines);
                    AsbSettlRevaluationLines.RUNMODAL;
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
                    // <-- 003.168 LKA 20200730
                    ProductionSettlementDialog.LOOKUPMODE := TRUE;
                    ProductionSettlementDialog.InitPage(Rec, Rec."Settlement Type"::Assembly);
                    IF ProductionSettlementDialog.RUNMODAL IN [ACTION::LookupOK, ACTION::OK] THEN BEGIN
                        ProductionSettlementDialog.GetRec(ProductionSettlementHeader);
                        AssemblySettlementCard.SETRECORD(ProductionSettlementHeader);
                        AssemblySettlementCard.RUN;
                    END;
                    // --> 003.168
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
    var
        ProductionSettlementHeader: Record "SC Prod.Settlement Header";
    begin
        Rec."Document Date" := TODAY;
        Rec."User Name" := USERID;
        Rec."Fixed Cost Item" := '.999.200.S0001';
        Rec."Variable Cost Item" := '.999.100.S0001';
        Rec."Settlement Type" := Rec."Settlement Type"::Assembly;
    end;

    trigger OnOpenPage()
    begin
        // <-- 003.125 LKA 20200407
        EditableDate := Rec.CheckDate(Rec."Date From");
        // --> 003.125
        // <-- 003.168 LKA 20200806
        Rec.FILTERGROUP(2);
        Rec.SETRANGE("Settlement Type", Rec."Settlement Type"::Assembly);
        // --> 003.168
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
        ProdSettlSummaryLines.CalcuateCostAllocation;
        ProdSettlSummaryLines.CalcuateCostAllocation;
        CurrPage.UPDATE(FALSE);
    end;
}

#pragma implicitwith restore

