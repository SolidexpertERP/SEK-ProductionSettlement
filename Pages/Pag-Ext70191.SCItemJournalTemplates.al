pageextension 70191 "SC Item Journal Templates" extends "Item Journal Templates"
{
    layout
    {
        addlast(Control1)
        {
            field("Gen. Bus. Posting Group"; Rec."Gen. Bus. Posting Group")
            {
                ApplicationArea = all;
            }
        }
    }
}
