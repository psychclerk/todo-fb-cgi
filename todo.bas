#lang "qb"

' Declare functions and subroutines
DECLARE SUB PrintHeader()
DECLARE SUB PrintForm()
DECLARE SUB PrintFooter()
DECLARE SUB ProcessForm()
DECLARE FUNCTION GetQueryValue$(query$, param$)
DECLARE FUNCTION URLDecode$(query$)
DECLARE FUNCTION Replace$(inputLine$, toReplace$, withReplace$)

' Get QUERY_STRING from environment
DIM shared queryString$, line$
queryString$ = ENVIRON$("QUERY_STRING")
queryString$ = URLDecode$(queryString$)

' Print the HTTP header and initial HTML structure
PrintHeader

' If the form has been submitted, process the form data
IF LEN(queryString$) > 0 THEN
    ProcessForm
ELSE
    ' Display the To-Do list form
    PrintForm
END IF

' Subroutine to print the CGI HTTP header and basic HTML structure
SUB PrintHeader
    PRINT "Content-Type: text/html"
    PRINT  ' Empty line to end header
    PRINT "<!DOCTYPE html>"
    PRINT "<html lang='en'>"
    PRINT "<head>"
    PRINT "<meta charset='UTF-8'>"
    PRINT "<meta name='viewport' content='width=device-width, initial-scale=1.0'>"
    PRINT "<title>To-Do List</title>"
    PRINT "<link rel='stylesheet' href='https://cdn.jsdelivr.net/gh/sphars/yacck/yacck.min.css'>"
    'PRINT "<link rel='stylesheet' href='https://unpkg.com/marx-css/css/marx.min.css'>"
    'PRINT "<link rel='stylesheet' href='./sakura.css'>"
    'PRINT "<link rel='stylesheet' href='https://cdn.jsdelivr.net/npm/@picocss/pico@2/css/pico.min.css'>"
    'PRINT "<style>"
    'PRINT "    body { font-family: Arial, sans-serif; "
    'Print "     body {        max-width: 80%;" 
    'print "             margin: 0 auto;}"
    'PRINT "</style>"
    PRINT "</head>"
    PRINT "<body>"
END SUB


SUB PrintFooter
    print "</main>"
    'PRINT "<footer>"
    '    print "<div>
    'Print "</footer>"
    PRINT "</body>"
    PRINT "</html>"
END SUB

' Subroutine to display the To-Do list form
SUB PrintForm
    print "<header>"
    print "<div>"
    PRINT "<h1>To-Do List</h1>"
    print "</div>"
    print "<nav>"
    print "<ul>"
    PRINT "<li><a href='?addtask=new'>[Add Task]</a></li>"
    PRINT "<li><a href='?donetasks=show'>[Done Task]</a></li>"
    print "</ul>"
    print "</nav>"
    print "</header>"

    PRINT "<div class='container'>"
    ' Display list of tasks in a table format by reading directly from the file
    print "<main>"
    PRINT "<h3>Task List:</h3>"
    PRINT "<table border='1'>"
    PRINT "<thead><tr><th>No.</th><th>Task</th><th>Actions</th></tr></thead>"
    
    OPEN "tasks.txt" FOR INPUT AS #1
    DIM i AS INTEGER
    i = 1
    
    DO WHILE NOT EOF(1)
        DIM line$
        LINE INPUT #1, line$
        
        'displayLine$ = line$
        'displayLine$ = Replace$(line$, "+", " ")
        'displayLine$ = Replace$(line$, "%2C", ",")
        
        
        ' Start the table row
        PRINT "<tr>"
        
        PRINT "<td>"; i;"</td>"
        ' Display the task in the first column
        PRINT "<td>" & line$ & "</td>"
        
        ' Display action links in the second column
        PRINT "<td>"
        PRINT "<a href='?edit=" & LTRIM$(STR$(i)) & "&oldtask=" & line$ & "'>[Edit]</a>"
        PRINT " <a href='?delete=" & line$ & "'>[Delete]</a>"
        PRINT " <a href='?moveup=" & LTRIM$(STR$(i)) & "'>[Up]</a>"
        PRINT " <a href='?movedown=" & LTRIM$(STR$(i)) & "'>[Down]</a>"
        print " <a href='?done=" & line$ & "'>[Done]</a>"
        PRINT "</td>"
        
        ' End the table row
        PRINT "</tr>"
        
        i = i + 1
    LOOP
    CLOSE #1
    
    PRINT "</table>"

  
    PRINT "</div>"
    PrintFooter
END SUB

' Subroutine to process form data (add, edit, delete, move task)
SUB ProcessForm
    print "<header>"
    print "<div>"
    PRINT "<h1>To-Do List</h1>"
    print "</div>"
    print "<nav>"
    print "<ul>"
    PRINT "<li><a href='?'>Go back to the To-Do List</a></li>"
    print "</ul>"
    print "</nav>"
    print "</header>"
    print "<main>"
    PRINT "<div class='container'>"
    DIM addTask AS STRING
    DIM editedTask AS STRING
    DIM deleteTask AS STRING
    DIM editIndex AS INTEGER
    DIM moveUpIndex AS INTEGER
    DIM moveDownIndex AS INTEGER
    DIM oldTask AS STRING
    DIM doneTask As STRING
    DIM doneTasks As STRING

    addTask = GetQueryValue$(queryString$, "addtask")
    editedTask = GetQueryValue$(queryString$, "editedtask")
    deleteTask = GetQueryValue$(queryString$, "delete")
    editIndex = VAL(GetQueryValue$(queryString$, "edit"))
    moveUpIndex = VAL(GetQueryValue$(queryString$, "moveup"))
    moveDownIndex = VAL(GetQueryValue$(queryString$, "movedown"))
    oldTask = GetQueryValue$(queryString$, "oldtask")
    doneTask = GetQueryValue$(queryString$, "done")
    doneTasks = GetQueryValue$(queryString$, "donetasks")

    IF addTask = "new" THEN
        
        PRINT "<form method='GET' action=''>"
        PRINT "<label>Add Task:</label>"
        PRINT "<input type='text' id='addtask' name='addtask'required>"
        PRINT "<input type='submit' value='Add task'>"
        PRINT "</form>"
    
    Elseif Len(addTask) > 0 and addTask <> "new" then      
        ' Add new task directly to file
        OPEN "tasks.txt" FOR APPEND AS #1
        PRINT #1, addTask
        CLOSE #1
        PRINT "<p>Task added!</p>"
        PRINT "<meta http-equiv='refresh' content='0; url=?'>"
    
    ELSEIF LEN(deleteTask) > 0 THEN
        ' Delete specified task by rewriting file without it
        OPEN "tasks.txt" FOR INPUT AS #1
        OPEN "temp.txt" FOR OUTPUT AS #2
        
        PRINT "<p>"; deleteTask; "</p>"

        DO WHILE NOT EOF(1)
            DIM line$
            LINE INPUT #1, line$
            IF RTRIM$(line$) <> deleteTask THEN
                PRINT #2, line$
                Print "<p> Here"; line$; "</p>"
            END IF
        LOOP

        CLOSE #1
        CLOSE #2

        ' Replace original file with updated file
        KILL "tasks.txt"
        NAME "temp.txt" AS "tasks.txt"

        PRINT "<p>Task deleted!</p>"
        PRINT "<meta http-equiv='refresh' content='0; url=?'>"

    ELSEIF editIndex > 0 THEN
        ' Edit the specified task
        oldTask = oldTask$
        'oldTask = Replace$(oldTask$, "+", " ")
        PRINT "<form method='GET' action=''>"
        PRINT "<label for='edittask'>Edit Task:</label>"
        PRINT "<input type='text' id='editedtask' name='editedtask' value='" & oldTask & "' required>"
        PRINT "<input type='hidden' name='editindex' value='" & LTRIM$(STR$(editIndex)) & "'>"
        PRINT "<input type='submit' value='Save Changes'>"
        PRINT "</form>"
        
    ELSEIF LEN(GetQueryValue$(queryString$, "editindex")) > 0 THEN
        ' Save the edited task to file
        editIndex = VAL(GetQueryValue$(queryString$, "editindex"))
        editedTask = GetQueryValue$(queryString$, "editedtask")
        
        OPEN "tasks.txt" FOR INPUT AS #1
        OPEN "temp.txt" FOR OUTPUT AS #2

        i = 1
        DO WHILE NOT EOF(1)
            LINE INPUT #1, line$
            IF i = editIndex THEN
                PRINT #2, editedTask
            ELSE
                PRINT #2, line$
            END IF
            i = i + 1
        LOOP

        CLOSE #1
        CLOSE #2

        KILL "tasks.txt"
        NAME "temp.txt" AS "tasks.txt"

        PRINT "<p>Task edited!</p>"
        PRINT "<meta http-equiv='refresh' content='0; url=?'>"
        
    ELSEIF LEN(doneTask) > 0 THEN
        
        ' Delete specified task by rewriting file without it
        OPEN "tasks.txt" FOR INPUT AS #1
        OPEN "temp.txt" FOR OUTPUT AS #2
        OPEN "done.txt" FOR APPEND as #3 
        
        PRINT "<p>"; deleteTask; "</p>"

        DO WHILE NOT EOF(1)
            LINE INPUT #1, line$
            IF RTRIM$(line$) <> doneTask THEN
                PRINT #2, line$
            ELSE
                PRINT #3, line$
            END IF
        LOOP

        CLOSE #1
        CLOSE #2
        CLOSE #3 

        ' Replace original file with updated file
        KILL "tasks.txt"
        NAME "temp.txt" AS "tasks.txt"

        PRINT "<meta http-equiv='refresh' content='0; url=?'>"

    ELSEIF moveUpIndex > 1 THEN
        ' Move the task up in the list
        OPEN "tasks.txt" FOR INPUT AS #1
        OPEN "temp.txt" FOR OUTPUT AS #2

        i = 1
        DIM prevTask AS STRING

        DO WHILE NOT EOF(1)
            LINE INPUT #1, line$
            IF i = moveUpIndex - 1 THEN
                prevTask = line$
            ELSEIF i = moveUpIndex THEN
                PRINT #2, line$
                PRINT #2, prevTask
            ELSE
                PRINT #2, line$
            END IF
            i = i + 1
        LOOP

        CLOSE #1
        CLOSE #2

        KILL "tasks.txt"
        NAME "temp.txt" AS "tasks.txt"

        PRINT "<p>Task moved up!</p>"
        PRINT "<meta http-equiv='refresh' content='0; url=?'>"
    
    ELSEIF moveUpIndex = 1 THEN 
        PRINT "<meta http-equiv='refresh' content='0; url=?'>"
        
    ELSEIF moveDownIndex > 0 THEN
        ' Move the task down in the list
        OPEN "tasks.txt" FOR INPUT AS #1
        OPEN "temp.txt" FOR OUTPUT AS #2

        i = 1
        DIM nextTask AS STRING
        DIM totalLines AS INTEGER
        
        DO WHILE NOT EOF(1)
            LINE INPUT #1, line$
            totalLines = totalLines + 1
        LOOP
        
        IF moveDownIndex = totalLines THEN 
            PRINT "<p>Cannot move down the last task.</p>"
            PRINT "<meta http-equiv='refresh' content='0; url=?'>"
            CLOSE #1
            CLOSE #2
        ELSE 
            SEEK #1, 1
            i = 1 
            DO WHILE NOT EOF(1)
                LINE INPUT #1, line$
                IF i = moveDownIndex THEN
                    nextTask = line$
                ELSEIF i = moveDownIndex + 1 THEN
                    PRINT #2, line$
                    PRINT #2, nextTask
                ELSE
                    PRINT #2, line$
                END IF
                i = i + 1
            LOOP
            CLOSE #1
            CLOSE #2
    
            KILL "tasks.txt"
            NAME "temp.txt" AS "tasks.txt"
    
            PRINT "<p>Task moved down!</p>"
            PRINT "<meta http-equiv='refresh' content='0; url=?'>"
        END IF    

    ELSEIF LEN(doneTasks) > 0 THEN
        PRINT "<h3>Done Tasks List</h3>"
        PRINT "<table border='1'>"
        PRINT "<thead><tr><th>No.</th><th>Task</th></tr></thead>"
    
        OPEN "done.txt" FOR INPUT AS #1
        i = 1
    
        DO WHILE NOT EOF(1)
            LINE INPUT #1, line$
   
            ' Start the table row
            PRINT "<tr>"
        
            PRINT "<td>"; i;"</td>"
            ' Display the task in the first column
            PRINT "<td>" & line$ & "</td>"
        
            ' End the table row
            PRINT "</tr>"
        
            i = i + 1
        LOOP
        CLOSE #1
    
        PRINT "</table>"
    END IF

    ' Link back to the main form
    'PRINT 
    print "</div>"
    PrintFooter
END SUB

' Function to extract values from the query string
FUNCTION GetQueryValue$ (query$, param$)
    DIM position AS INTEGER
    DIM startPos AS INTEGER
    DIM endPos AS INTEGER
    DIM paramWithEqual AS STRING

    paramWithEqual = param$ + "="
    position = INSTR(query$, paramWithEqual)
    IF position > 0 THEN
        startPos = position + LEN(paramWithEqual)
        endPos = INSTR(startPos, query$, "&")
        IF endPos = 0 THEN endPos = LEN(query$) + 1
        GetQueryValue$ = MID$(query$, startPos, endPos - startPos)
    ELSE
        GetQueryValue$ = ""
    END IF
END FUNCTION

' Function to replace all "+" characters in a string with spaces
FUNCTION Replace$ (inputLine$, toReplace$, withReplace$)
    DIM result$ 
    result$ = ""
    
    FOR i = 1 TO LEN(inputLine$)
        IF MID$(inputLine$, i, 1) = toReplace$ THEN
            result$ = result$ + withReplace$
        ELSE
            result$ = result$ + MID$(inputLine$, i, 1)
        END IF
    NEXT i
    
    Replace$ = result$
END FUNCTION

FUNCTION URLDecode$(query$)
    DIM result$ 
    result$ = ""
    i=1
    
    FOR i = 1 TO LEN(query$)
        DIM char$
        char$ = MID$(query$, i, 1)
        
        IF char$ = "%" THEN
            ' Read the next two characters as hexadecimal
            DIM hexValue$
            hexValue$ = MID$(query$, i + 1, 2)
            DIM asciiValue AS INTEGER
            asciiValue = VAL("&H" & hexValue$)  ' Convert hex to ASCII
            result$ = result$ + CHR$(asciiValue)
            i = i + 2  ' Skip the next two characters
        ELSEIF char$ = "+" THEN
            result$ = result$ + " "  ' Convert + to space
        ELSE
            result$ = result$ + char$
        END IF
    NEXT i
    
    URLDecode$ = result$
END FUNCTION
