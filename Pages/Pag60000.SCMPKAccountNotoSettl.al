page 60000 "SC MPK - Account No. to Settl."
{
    Caption = 'Map. nr kont do wymiaru MPK';
    Description = '003.168';
    PageType = List;
    SourceTable = "SC Account No. - MPK Code";
    ApplicationArea = all;
    UsageCategory = Tasks;
    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("MPK Dimension"; Rec."MPK Dimension")
                {
                    ApplicationArea = all;
                }
                field("Work Type Code"; Rec."Work Type Code")
                {
                    ApplicationArea = all;
                }
                field("Account No. 6"; Rec."Account No. 6")
                {
                    ApplicationArea = all;
                }
                field("Account No. 4"; Rec."Account No. 4")
                {
                    ApplicationArea = all;
                }
                field("Account No. 7"; Rec."Account No. 7")
                {
                    ApplicationArea = all;
                }
            }
        }
    }

    actions
    {
    }
}