Tidy Keyword Trends
===================
Processes Google Keyword Planner data into a tidy format (long) showing monthly and quarterly volumes per keyword
-----------------------------------------------------------------------------------------------------------------

This script converts (a set of) csv's from Google's Keyword Planner into a tidy data set suitable for further analysis or visualisation in tools such as R, Tableau, etc..

### Acquiring data

Acquire your data as follows:

1. In Google AdWords Center, go to 'Tools' >> 'Keyword Planner' and choose the fourth option ('Get clicks and performance forecasts')
2. Enter or upload a list of keywords (max 3.000), set your targeting options and click 'Get forecasts'
3. Click the 'Download' button between the line graph and table with keyword groups. In the following screen, tick the box before 'Segment by month' and click 'Download'.
4. Make sure your file is stored as a csv-file in the same directory as the script.
5. If you want to process trend data for more than 3.000 words, split your set in pieces of 3.000 keywords, and repeat the steps above.

### Processing the data

The script consists of four parts of which loading the data is obligatory in order to process it into monthly or quarterly data.

#### Loading the data

This part automatically imports and combines all csv-files in the working directory and stores it in a data frame.

* Make sure the csv-files with raw data are stored in your working directory
* Make sure there are no other csv-files than the raw data downloaded from Google.

#### Processing Monthly Data

In order to generate monthly keyword volumes, this part of the script does the following:

1. Melts al data along keywords
2. Extracts the date and stores it in the date-column
3. Filters obsolete rows
4. Stores the tidy data in a data frame

#### Extrapolating Volumes for Missing Months

When you download keyword data in the beginning of the month, Google sometimes does not offer the volumes for the previous month yet. This part of the script calculates the avarage of the most recent and least recent month (e.g.: takes the average of february 2015 and april 2014 to calculute march 2015).

1. Selects the months to use and to extrapolate for
2. Extrapolates volumes for all keywords in a seperate data frame
3. Joins the original data frame with the data frame with extrapolated data
4. Stores the tidy data in a data frame

#### Processing Quarterly Data

This part of the scripts uses the (extrapolated) monthly data to calculate keyword volumes for every quarter.

1. Adds a column to the monthly data indicating the quarter
2. Groups keywords and volumes per quarter
3. Stores the tidy data in a data frame

#### Exporting Data

Exports the monthly and/or quarterly data as csv-files.