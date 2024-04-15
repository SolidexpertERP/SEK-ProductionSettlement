pageextension 70170 "SC Assembly Setup" extends "Assembly Setup"
{
    layout
    {
        addlast(Numbering)
        {
            field("Assembly Settl. Cost Nos."; Rec."Assembly Settl. Cost Nos.")
            {
                ApplicationArea = all;
            }
        }
    }
}
