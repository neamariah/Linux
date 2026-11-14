#!/usr/bin/env bash

OUTPUT_DIR="/var/www/html/week3"
TEMP_FILE=$(mktemp)

GENERATED_AT=$(date '+%Y-%m-%d %H:%M:%S %Z')
UPTIME_TEXT=$(uptime -p)
DISK_USAGE=$(df -P / | awk 'NR == 2 {print $5}')
MEM_TOTAL=$(free -m | awk '/^Mem:/ {print $2}')
MEM_AVAILABLE=$(free -m | awk '/^Mem:/ {print $7}')

get_disk_status() {
    local usage="$1"

    if (( usage < 80 )); then
        echo "OK"
    else
        echo "WARNING"
    fi
} 

DISK_STATUS=$(get_disk_status "${DISK_USAGE%\%}")
cat > "$TEMP_FILE" <<EOF
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Week 3 – Server Status Report</title>
    <style>
        body {
            font-family: system-ui, sans-serif;
            max-width: 900px;
            margin: 40px auto;
            padding: 0 20px;
            line-height: 1.6;
            background: #f1f5f9;
            color: #172033;
        }

        h1, h2 {
            color: #173b65;
        }

        section {
            margin: 24px 0;
            padding: 24px;
            background: white;
            border-radius: 12px;
        }

        .table-container {
            overflow-x: auto;
        }

        table {
            border-collapse: collapse;
            width: 100%;
        }

        th, td {
            border: 1px solid #cbd5e1;
            padding: 12px;
            text-align: left;
        }

        th {
            background: #dbeafe;
        }

        code {
            background: #e2e8f0;
            padding: 2px 5px;
            border-radius: 4px;
            overflow-wrap: anywhere;
        }

        a {
            color: #1746a2;
        }

        .note {
            color: #475569;
        }
    </style>
</head>
<body>
    <header>
        <h1>Server Status Report</h1>
        <p>Week 3: Linux command line and Bash scripting</p>
        <p>This web page presents the Linux-server's status and disc usage. The report is automatically generated using a Bash script.</p>
        </header>

    <section>
        <h2>Current server status</h2>

        <div class="table-container">
            <table>
                <thead>
                    <tr>
                        <th scope="col">Information</th>
                        <th scope="col">Value</th>
                    </tr>
                </thead>
                <tbody>
                    <tr>
                        <th scope="row">Report generated</th>
                        <td>$GENERATED_AT</td>
                    </tr>
                    <tr>
                        <th scope="row">Server uptime</th>
                        <td>$UPTIME_TEXT</td>
                    </tr>
                    <tr>
                        <th scope="row">Root filesystem disk usage</th>
                        <td>$DISK_USAGE</td>
                    </tr>
                    <tr>
                        <th scope="row">Disk space status</th>
                        <td>$DISK_STATUS</td>
                    </tr>
                    <tr>
                        <th scope="row">Total RAM</th>
                        <td>$MEM_TOTAL MiB</td>
                    </tr>
                    <tr>
                        <th scope="row">Available RAM</th>
                        <td>$MEM_AVAILABLE MiB</td>
                    </tr>
                </tbody>
            </table>
        </div>

        <p>
            Disk space status is <strong>OK</strong> below 80% usage
            and <strong>WARNING</strong> at 80% or above.
        </p>

        <p class="note">
            Bash generates this report once per minute.
            Wait approximately 1–2 minutes and reload the page
            to see a new generation time.
        </p>
    </section>

    <section>
        <h2>Commands used</h2>
        <ul>
            <li>
                <code>date</code>:
                displays the current date, time and time zone
                using the format specified in the script.
            </li>
            <li>
                <code>uptime -p</code>:
                displays how long the server has been running.
            </li>
            <li>
                <code>df -P / | awk 'NR == 2 {print &#36;5}'</code>:
                passes filesystem information to awk, which extracts
                the usage percentage from the second row.
            </li>
            <li>
                <code>free -m</code>:
                displays memory information in mebibytes (MiB).
            </li>
        </ul>
    </section>

    <section>
        <h2>How the script works</h2>
        <p>
            The script collects server information using Linux commands
            and stores the results in Bash variables through command
            substitution. A function uses an if statement to determine
            the disk space status.
        </p>
        <p>
            The script generates a temporary HTML file and then moves
            the completed file into place as index.html.
            Nginx serves this file at /viikko3/.
        </p>
        <p>
            With the function get_disk_status it is possible to check the disk usage percentage. When the usage is below 80%, it returns "OK." When the percentage goes 80% or above, it returns "WARNING."
<p> With the pipe you can pass the output of one command to another one. 
        </p>
    </section>

    <section>
        <h2>Scheduling</h2>
        <p>
            Here I used cron to schedule Bash script. It should be running automatically once every minute and the service is enabled and running on the server. The crontab entry remains savedd so the schedule task continues after rebooting.
        </p>
    </section>

    <section>
        <h2>Test results</h2>

        <h3>Syntax check and manual execution</h3>
        <p>
            I tested the script syntax using: bash -n viikko.sh and didn't get any syntax errors. I also used the manual (bash viikko3.sh) and everything was working as expected while displaying the information needed(date, uptime etc.)
        </p>

        <h3>Disk space status tests</h3>
        <p>
            Test the status logic using temporary input values.
            Record your actual results below and restore real disk
            usage afterwards.
        </p>

        <div class="table-container">
            <table>
                <thead>
                    <tr>
                        <th scope="col">Test input</th>
                        <th scope="col">Expected status</th>
                        <th scope="col">Actual status</th>
                    </tr>
                </thead>
                <tbody>
                    <tr>
                        <td>50%</td>
                        <td>OK</td>
                        <td>OK</td>
                    </tr>
                    <tr>
                        <td>80%</td>
                        <td>WARNING</td>
                        <td>WARNING</td>
                    </tr>
                    <tr>
                        <td>90%</td>
                        <td>WARNING</td>
                        <td>WARNING</td>
                    </tr>
                </tbody>
            </table>
        </div>

        <h3>Automatic updates</h3>
        <p>
            By using the stat command I was able to verify that the cron job runs every minute. (My first update was 13:47:01 and the second one 13:48:01.)
        </p>

        <h3>Reboot test</h3>
        <p>
            After rebooting the week2 application and week 3 page were both working. Also the cron service was running and the report continued to update automatically. With the stat command I confirmed that after the reboot had been updated automatically, since the modification time showed 13:57:01.
        </p>
    </section>

    <section>
        <h2>A problem solved or a lesson learned</h2>
        <p>For me, understanding how the pipe symbol works, how/when it is used in Bash was challenging. After studying about it and finding different examples I understood how they work and how they can be used to process information.</p>
    </section>

    <footer>
        <p><a href="$GITHUB_URL">View the source code on GitHub</a></p>
    </footer>
</body>
</html>
EOF

mv "$TEMP_FILE" "$OUTPUT_DIR/index.html"
chmod 644 "$OUTPUT_DIR/index.html"

echo "Date, time and timezone: $GENERATED_AT"
echo "Server's uptime: $UPTIME_TEXT"
echo "Disc usage: $DISK_USAGE"
echo "Disc status: $DISK_STATUS"
echo "Total RAM: $MEM_TOTAL MiB"
echo "Available RAM: $MEM_AVAILABLE MiB"
