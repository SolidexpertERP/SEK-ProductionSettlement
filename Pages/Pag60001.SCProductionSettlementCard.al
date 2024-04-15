page 60001 "SC Production Settlement Card"
{

    Caption = 'Rozliczenie produkcji';
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
                    Enabled = false;
                }
                field(Status; Rec.Status)
                {
                    ApplicationArea = all;
                    Editable = false;
                }
                field("Document Type"; Rec."Document Type")
                {
                    ApplicationArea = all;
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
                        EditableDate := Rec.CheckDate(Rec."Date From");
                    end;
                }
                field(Year; Rec.Year)
                {
                    ApplicationArea = all;
                    Editable = EditableDate;
                    ShowMandatory = true;

                    trigger OnValidate()
                    begin
                        EditableDate := Rec.CheckDate(Rec."Date From");
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
            part(ProdSettlSubformLines; "SC Prod. Settl. Subform Lines")
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
                Caption = 'Wygeneruj';
                Image = CalculateLines;
                ApplicationArea = all;

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

                    CurrPage.UPDATE(FALSE);
                end;
            }
            action("Generate Item Jnl Lines")
            {
                Caption = 'Wygeneruj dziennik zapasów';
                Image = InventoryJournal;
                ApplicationArea = all;

                trigger OnAction()
                var
                    ProdSettlSummaryLines: Record "SC Prod. Settl. Summary Lines";
                    ProdSettlItemJnlLines: Report "SC Prod. Item Jnl. Lines";
                begin
                    IF Rec."Settlement Type" <> Rec."Settlement Type"::Production THEN
                        ERROR('Tej funckji można użyć tylko dla typu rozliczenia Produkcja');

                    IF Rec."Document Type" <> Rec."Document Type"::Settlement THEN
                        ERROR('Tej funkcji nie można użyć dla typu dokumentu korekta');

                    ProdSettlSummaryLines.RESET;
                    ProdSettlSummaryLines.SETRANGE("Document No.", Rec."No.");
                    ProdSettlItemJnlLines.SETTABLEVIEW(ProdSettlSummaryLines);
                    ProdSettlItemJnlLines.RUNMODAL;
                    CurrPage.UPDATE(FALSE);
                end;
            }
            action("Generate Consumption Journal Lines")
            {
                Caption = 'Wygeneruj dziennik zużycia';
                Image = CapacityJournal;
                Visible = Rec."Document Type" = Rec."Document Type"::Settlement;
                ApplicationArea = all;

                trigger OnAction()
                var
                    ProdSettlSummaryLines: Record "SC Prod. Settl. Summary Lines";
                    ProdSettlConsumpLines: Report "SC Prod. Settl. Consump. Lines";
                begin
                    IF Rec."Settlement Type" <> Rec."Settlement Type"::Production THEN
                        ERROR('Tej funckji można użyć tylko dla typu rozliczenia Produkcja');

                    ProdSettlSummaryLines.RESET;
                    ProdSettlSummaryLines.SETRANGE("Document No.", Rec."No.");
                    ProdSettlConsumpLines.SETTABLEVIEW(ProdSettlSummaryLines);
                    ProdSettlConsumpLines.RUNMODAL;
                    CurrPage.UPDATE(FALSE);
                end;
            }
            action("Generate Revaluationl Lines")
            {
                Caption = 'Wygeneruj dziennik przeszacowań';
                Image = CapacityJournal;
                Visible = Rec."Document Type" = Rec."Document Type"::Correction;
                ApplicationArea = all;
                trigger OnAction()
                var
                    ProdSettlSummaryLines: Record "SC Prod. Settl. Summary Lines";
                    ProdSettlRevalLines: Report "SC Prod. Settl. Reval. Lines";
                begin
                    IF Rec."Settlement Type" <> Rec."Settlement Type"::Production THEN
                        ERROR('Tej funckji można użyć tylko dla typu rozliczenia Produkcja');

                    ProdSettlSummaryLines.RESET;
                    ProdSettlSummaryLines.SETRANGE("Document No.", Rec."No.");
                    ProdSettlRevalLines.SETTABLEVIEW(ProdSettlSummaryLines);
                    ProdSettlRevalLines.RUNMODAL;
                    CurrPage.UPDATE(FALSE);
                end;
            }
            action("Oblicz alokację kosztów")
            {
                Caption = 'Oblicz alokację kosztów';
                Image = Recalculate;
                ApplicationArea = all;
                trigger OnAction()
                var
                    ProdSettlSummaryLines: Record "SC Prod. Settl. Summary Lines";
                begin
                    CalcAlocation;
                    CalcAlocation;
                    MESSAGE('Alokacja kosztów została obliczona');
                end;
            }
            action(New)
            {
                Caption = 'Nowe';
                Description = '003.168';
                Image = NewDocument;
                ApplicationArea = all;
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
                    ProductionSettlementDialog.InitPage(Rec, Rec."Settlement Type"::Production);
                    IF ProductionSettlementDialog.RUNMODAL IN [ACTION::LookupOK, ACTION::OK] THEN BEGIN
                        ProductionSettlementDialog.GetRec(ProductionSettlementHeader);
                        ProductionSettlementCard.SETRECORD(ProductionSettlementHeader);
                        ProductionSettlementCard.RUN;
                    END;
                    // --> 003.168
                end;
            }
            action("Generate Journal")
            {
                Caption = 'Wygeneruj wiersze dziennika';
                Image = GeneralPostingSetup;
                ApplicationArea = all;
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
        Rec."Fixed Cost Item" := '.999.200.S0001';
        Rec."Variable Cost Item" := '.999.100.S0001';
        Rec."Settlement Type" := Rec."Settlement Type"::Production;
    end;

    trigger OnOpenPage()
    begin
        // <-- 003.125 LKA 20200407
        EditableDate := Rec.CheckDate(Rec."Date From");
        // --> 003.125

        // <-- 003.168 LKA 20200806
        Rec.FILTERGROUP(2);
        Rec.SETRANGE("Settlement Type", Rec."Settlement Type"::Production);
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
        CurrPage.UPDATE(FALSE);
    end;
}

