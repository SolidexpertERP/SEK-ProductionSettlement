pageextension 70175 "SC Resource Group" extends "Resource Groups"
{
    layout
    {
        addlast(Control1)
        {
            field("Default Resource Group Filter"; Rec."Default Resource Group Filter")
            {
                ApplicationArea = all;
            }
        }

    }
}
