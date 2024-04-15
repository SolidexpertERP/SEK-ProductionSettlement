#pragma implicitwith disable
page 60012 "SC Production Settlement List"
{
    Caption = 'Rozliczenia produkcji';
    InsertAllowed = false;
    ModifyAllowed = false;
    PageType = List;
    SourceTable = "SC Prod.Settlement Header";
    SourceTableView = WHERE("Settlement Type" = CONST(Production));
    ApplicationArea = all;
    UsageCategory = Lists;
    CardPageId = "SC Production Settlement Card";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("No."; Rec."No.")
                {
                    ApplicationArea = all;
                }
                field("Settlement Type"; Rec."Settlement Type")
                {
                    ApplicationArea = all;
                }
                field(Status; Rec.Status)
                {
                    ApplicationArea = all;
                }
                field("Document Date"; Rec."Document Date")
                {
                    ApplicationArea = all;
                }
                field("User Name"; Rec."User Name")
                {
                    ApplicationArea = all;
                }
                field("Date From"; Rec."Date From")
                {
                    ApplicationArea = all;
                }
                field("Date To"; Rec."Date To")
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
            }
        }
    }

    actions
    {
        area(processing)
        {
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
                    ProductionSettlementDialog.InitPage(Rec, Rec."Settlement Type"::Production);
                    IF ProductionSettlementDialog.RUNMODAL IN [ACTION::LookupOK, ACTION::OK] THEN BEGIN
                        ProductionSettlementDialog.GetRec(ProductionSettlementHeader);
                        ProductionSettlementCard.SETRECORD(ProductionSettlementHeader);
                        ProductionSettlementCard.RUN;
                    END;
                    // --> 003.168
                end;
            }
            /*action(Edit)
            {
                Caption = 'Edytuj';
                Description = '003.168';
                Image = Edit;
                Promoted = true;
                PromotedCategory = New;
                RunObject = Page "SC Production Settlement Card";
                RunPageOnRec = true;
                PromotedIsBig = true;
                PromotedOnly = true;
            }*/
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
}

#pragma implicitwith restore

