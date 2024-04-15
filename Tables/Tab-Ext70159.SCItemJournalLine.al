tableextension 70159 "SC Item Journal Line" extends "Item Journal Line"
{

    trigger OnInsert()
    var
        ItemJnlTemplate: Record "Item Journal Template";
    begin
        if ItemJnlTemplate.Get("Journal Template Name") then
            IF ItemJnlTemplate."Gen. Bus. Posting Group" <> '' THEN
                VALIDATE("Gen. Bus. Posting Group", ItemJnlTemplate."Gen. Bus. Posting Group");
    end;

}
