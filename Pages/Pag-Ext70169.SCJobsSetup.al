pageextension 70169 "SC Jobs Setup" extends "Jobs Setup"
{
    layout
    {
        addlast(Numbering)
        {
            field("Job Settl. Cost Nos."; Rec."Job Settl. Cost Nos.")
            {
                ApplicationArea = all;
            }
        }
    }
}
