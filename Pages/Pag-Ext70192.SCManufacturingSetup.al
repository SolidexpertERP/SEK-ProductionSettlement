pageextension 70192 "SC Manufacturing Setup" extends "Manufacturing Setup"
{
    layout
    {
        addlast(Numbering)
        {
            field("Prod. Settl. Cost Nos."; Rec."Prod. Settl. Cost Nos.")
            {
                Description = '003.125';
                ApplicationArea = all;
            }
        }
    }
}