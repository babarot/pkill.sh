#!awk -f

BEGIN {
    OFS = "\t"
}

$1 == user {
    commands = ""
    if ($11 ~ "/Applications/") {
        next
    }
    printf("\033[40m%s\t%s\t%s\t\033[m", $2, $9, $10)
    for (i = 11; i <= NF; i++) {
        if (i == 11) {
            $i = "\033[32m" $i "\033[m"
        }
        commands = commands " " $i
    }
    if (commands != "") print commands
}
