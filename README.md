# TStringGridHelper
##TStringGridHelper Class to Facilitate Sorting Columns Using Underlying TFDQuery DataSet

This class is intended for use under the following circumstances:

* This is a VCL project. (May work for Firemonkey but I haven't tried it.)
* A TStringGrid component is used to display data from a TFDQuery.
* Livebindings are used to connect the TFDQuery and the TStringGrid.
* A desired feature is the ability to click a column heading and have the TStringGrid display the data in ascending order based on that column's contents.

The code consists of a single file that contains a single class, TStringGridHelper. To use it:

* Download the file
* Include the file in your project that meets the criteria outlined above
* In the unit with your TStringGrid (typically the main form) include the TStringGridHelper.pas unit in the USES clause.
* See the comments in the TStringGridHelper.pas file for details on utilization. In general:
  * Configure the TStringGrid with goColMoving = False
  * goFixedColClick = True
  * goFixedRowClick = True
  * Invoke the sort from the OnFixedCellClick event
    ```pascal
    TStringGrid(Sender).SortRecords(BindingsList1, TStringGrid(Sender).Cells[ACol, ARow]);
    ```
    
License file added 8/24/17. See file list.
    
Coming soon:
* A blog entry with more explanatin and detail.
