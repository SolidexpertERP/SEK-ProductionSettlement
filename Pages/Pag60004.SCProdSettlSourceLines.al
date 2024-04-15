#pragma implicitwith disable
page 60004 "SC Prod. Settl. Source Lines"
{
    Caption = 'Rozliczenie produkcji - wiersze źródłowe';
    DeleteAllowed = false;
    Editable = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    PageType = List;
    SourceTable = "SC Prod. Settl. Source Line";
    UsageCategory = None;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Document No."; Rec."Document No.")
                {
                    ApplicationArea = all;
                }
                field("Line No."; Rec."Line No.")
                {
                    ApplicationArea = all;
                }
                field("OBIEKT Dim Value"; Rec."OBIEKT Dim Value")
                {
                    ApplicationArea = all;
                }
                field("Fixed/Variable Costs"; Rec."Fixed/Variable Costs")
                {
                    ApplicationArea = all;
                }
                field("G/L Entry No."; Rec."G/L Entry No.")
                {
                    ApplicationArea = all;

                    trigger OnAssistEdit()
                    var
                        GLEntry: Record "G/L Entry";
                    begin
                        GLEntry.RESET;
                        GLEntry.SETRANGE("Entry No.", Rec."G/L Entry No.");
                        PAGE.RUN(PAGE::"General Ledger Entries", GLEntry);
                    end;
                }
                field("G/L Account No."; Rec."G/L Account No.")
                {
                    ApplicationArea = all;
                }
                field("Posting Date"; Rec."Posting Date")
                {
                    ApplicationArea = all;
                }
                field("Document Type"; Rec."Document Type")
                {
                    ApplicationArea = all;
                }
                field("G/L Entry Document No."; Rec."G/L Entry Document No.")
                {
                    ApplicationArea = all;
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = all;
                }
                field(Amount; Rec.Amount)
                {
                    ApplicationArea = all;
                }
                field(Quantity; Rec.Quantity)
                {
                    ApplicationArea = all;
                }
                field("VAT Amount"; Rec."VAT Amount")
                {
                    ApplicationArea = all;
                }
                field("Debit Amount"; Rec."Debit Amount")
                {
                    ApplicationArea = all;
                }
                field("Credit Amount"; Rec."Credit Amount")
                {
                    ApplicationArea = all;
                }
                field("Document Date"; Rec."Document Date")
                {
                    ApplicationArea = all;
                }
                field("External Document No."; Rec."External Document No.")
                {
                    ApplicationArea = all;
                }
                field("Source Type"; Rec."Source Type")
                {
                    ApplicationArea = all;
                }
                field("Source No."; Rec."Source No.")
                {
                    ApplicationArea = all;
                }
            }
        }
    }

    actions
    {
        area(navigation)
        {
            group("Ent&ry")
            {
                Caption = 'Zapis';
                Image = Entry;
                action(Dimensions)
                {
                    ApplicationArea = all;
                    AccessByPermission = TableData 348 = R;
                    Caption = 'Wymiary';
                    Image = Dimensions;
                    Scope = Repeater;
                    ShortCutKey = 'Shift+Ctrl+D';

                    trigger OnAction()
                    begin
                        Rec.ShowDimensions;
                        CurrPage.SAVERECORD;
                    end;
                }
            }
        }
        area(processing)
        {
            action("&Navigate")
            {
                ApplicationArea = all;
                Caption = 'Nawiguj';
                Image = Navigate;

                trigger OnAction()
                var
                    Navigate: Page Navigate;
                begin
                    Navigate.SetDoc(Rec."Posting Date", Rec."G/L Entry Document No.");
                    Navigate.RUN;
                end;
            }
        }
    }
}

#pragma implicitwith restore

