package platform;

enum abstract MenuItemType(String) from String to String {
    var Normal = "normal";
    var Checkbox = "checkbox";
    var Separator = "separator";
}