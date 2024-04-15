page 60003 "SC Prod. Settl. Det. Src. Line"
{
    Caption = 'Szczegółowe wiersze sumaryczne';
    DeleteAllowed = false;
    Editable = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    PageType = List;
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
                field("G/L Account No."; Rec."G/L Account No.")
                {
                    ApplicationArea = all;
                }
                field("Fixed Costs Amount"; Rec."Fixed Costs Amount")
                {
                    ApplicationArea = all;

                    trigger OnAssistEdit()
                    begin
                        LookupPage(Rec.FIELDNO("Fixed Costs Amount"));
                    end;
                }
                field("Variable Costs Amount"; Rec."Variable Costs Amount")
                {
                    ApplicationArea = all;

                    trigger OnAssistEdit()
                    begin
                        LookupPage(Rec.FIELDNO("Variable Costs Amount"));
                    end;
                }
            }
        }
    }

    actions
    {
    }

    var
        ShowGLAccount: Boolean;

    local procedure LookupPage(FieldNo: Integer)
    var
        ProdSettlSourceLines: Record "SC Prod. Settl. Source Line";
    begin
        ProdSettlSourceLines.RESET;

        ProdSettlSourceLines.SETRANGE("OBIEKT Dim Value", Rec."OBIEKT Dim Value");
        ProdSettlSourceLines.SETRANGE("G/L Account No.", Rec."G/L Account No.");

        CASE FieldNo OF
            200:
                ProdSettlSourceLines.SETRANGE("Fixed/Variable Costs", ProdSettlSourceLines."Fixed/Variable Costs"::Fixed);
            201:
                ProdSettlSourceLines.SETRANGE("Fixed/Variable Costs", ProdSettlSourceLines."Fixed/Variable Costs"::Variable);
        END;

        ProdSettlSourceLines.FILTERGROUP(2);
        ProdSettlSourceLines.SETRANGE("Document No.", Rec."Document No.");

        PAGE.RUN(PAGE::"SC Prod. Settl. Source Lines", ProdSettlSourceLines);
    end;
}

