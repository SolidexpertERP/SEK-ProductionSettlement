tableextension 70160 "SC Item Journal Template" extends "Item Journal Template"
{
    fields
    {
        field(60000; "Gen. Bus. Posting Group"; Code[20])
        {
            Caption = 'Gł. gospodarcza grupa księgowa';
            DataClassification = ToBeClassified;
            TableRelation = "Gen. Business Posting Group";
        }
    }
}
