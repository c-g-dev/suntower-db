package;

class UISelectors {
	public static var INSERT_LINE_ANCHOR = "#content > table > tr.selected > td > a";

    public static var CREATE_NEW_SHEET_ANCHOR = ".castle#content > a";
    public static var CREATE_NEW_SHEET_POPUP_CONFIRM = "#newsheet #sheet_form > p.buttons > input[type=submit]:nth-child(1)";
    public static var CREATE_NEW_SHEET_POPUP = "#newsheet";
    public static var CREATE_NEW_SHEET_POPUP_SHEET_NAME_INPUT = "#sheet_name";

    public static var ADD_A_COLUMN_ANCHOR = ".castle#content > table > a";

      
      public static var AUTOSAVE_CONFIG_POPUP = "#autosaveconfig";
      public static var AUTOSAVE_CONFIG_ENABLED_CHECKBOX = "#autosaveconfig #enabled";
      public static var AUTOSAVE_CONFIG_FOLDER_INPUT = "#autosaveconfig #folder";
      public static var AUTOSAVE_CONFIG_INTERVAL_INPUT = "#autosaveconfig #interval";
      public static var AUTOSAVE_CONFIG_MAX_BACKUPS_INPUT = "#autosaveconfig #max_backups";
      public static var AUTOSAVE_CONFIG_SAVE_BUTTON = "#autosaveconfig p.buttons > input[value='Save']";
      public static var AUTOSAVE_CONFIG_CANCEL_BUTTON = "#autosaveconfig p.buttons > input[value='Cancel']";
  
      
      public static var NEW_COLUMN_POPUP = "#newcol";
      public static var NEW_COLUMN_NAME_INPUT = "#newcol #col_form input[name='name']";
      public static var NEW_COLUMN_TYPE_SELECT = "#newcol #col_form select[name='type']";
      public static var NEW_COLUMN_POSSIBLE_VALUES_INPUT = "#col_options .values input[name='values']";
      public static var NEW_COLUMN_SHEET_SELECT = "#col_options .sheet select[name='sheet']";
      public static var NEW_COLUMN_DISPLAY_SELECT = "#col_options .disp select[name='display']";
      public static var NEW_COLUMN_LOCALIZABLE_CHECKBOX = "#col_options .localizable input[name='localizable']";
      public static var NEW_COLUMN_CUSTOM_TYPE_SELECT = "#col_options .custom select[name='ctype']";
      public static var NEW_COLUMN_CUSTOM_TYPE_CREATE_LINK = "#col_options .custom a.tcreate";
      public static var NEW_COLUMN_CUSTOM_TYPE_EDIT_LINK = "#col_options .custom a.tedit";
      public static var NEW_COLUMN_REQUIRED_CHECKBOX = "#col_options .opt input[name='req']";
      public static var NEW_COLUMN_CREATE_BUTTON = "#newcol #col_form p.buttons input.create[type='submit']";
      public static var NEW_COLUMN_MODIFY_BUTTON = "#newcol #col_form p.buttons input.edit[type='submit']";
      public static var NEW_COLUMN_CANCEL_BUTTON = "#newcol #col_form p.buttons input[value='Cancel']";
  
      
      public static var RUN_QUERY_POPUP = "#run-query-popup";
      public static var RUN_QUERY_INPUT = "#run-query-popup #query_input";
      public static var RUN_QUERY_RESULT_AREA = "#run-query-popup #result_area";
      public static var RUN_QUERY_BUTTON = "#run-query-popup #run_query_button";
      public static var RUN_QUERY_CLOSE_BUTTON = "#run-query-popup input[value='Close']";
  
      
      public static var SEARCH_INPUT = "#search input[name='search']";
      public static var SEARCH_CLEAR_BUTTON = "#search i.fa-times-circle";
  
      
      public static var ADD_COLUMN_LINK = "#content table a[href^='javascript:_.newColumn']";
  
      
      public static var SHEET_TABS_LIST = "#sheets";
      public static var SHEET_TABS = "#sheets li";
      public static var ACTIVE_SHEET_TAB = "#sheets li.active";
  
      
      public static var FILE_SELECT_INPUT = "#fileSelect";

      
        public static function CELL(x:Int, y:Int) {
            return "#content > table > tr:nth-child(" + (y + 2) +") > td:nth-child(" + (x + 2) + ")";
        }
}