if [[ $- != *i* ]]; then
    return 0
fi

# Define color codes
RESET='\033[0m'
BOLD='\033[1m'
UNDERLINE='\033[4m'
BLUE='\033[34m'
GREEN='\033[32m'
CYAN='\033[36m'
YELLOW='\033[33m'
MAGENTA='\033[35m'
RED='\033[31m'

# Function to display the ASCII Art Banner
display_banner() {
    echo -e "${BLUE}"
    cat << "EOF"
⠀⠈⠀⡀⠀⠈⢀⠀⢀⠈⠀⡀⠀⠈⢀⠀⢀⠈⠀⡀⠀⠈⢀⠀⢀⠈⠀⡀⠀⠈⢀⠀⢀⠈⠀⡀⠀⠈⢀⠀⢀⠈⣠⡀⠀⠈⢀⠀⢀⠈⠀
⠀⠈⠀⠀⡀⠁⠀⢀⠀⠀⠄⠀⢀⠁⠀⢀⠀⠀⠄⠀⢀⠁⠀⢀⠀⠀⠄⠀⢀⠁⠀⢀⠀⠀⠄⠀⢀⠁⠀⢀⢠⠞⣆⠸⡄⠁⠀⢀⠀⠀⠄
⡀⠁⠀⠁⠀⢀⠈⠀⠀⠄⠀⠂⠀⢀⠐⠀⠀⠄⠀⠂⠀⢀⠐⠀⠀⠄⠀⠂⠀⢀⠐⠀⠀⠄⠀⠂⠀⢀⠐⢀⢏⠐⠜⡆⢸⠀⠈⠀⠀⠠⠀
⠀⢀⠈⠀⠈⠀⠀⡀⠂⠀⠐⠀⠈⠀⠀⠠⠐⠀⠐⠀⠈⠀⠀⠠⠐⠀⠐⠀⠈⠀⠀⠠⠐⠀⠐⠀⠈⠀⢀⠏⠄⠅⠕⣳⠈⡎⠀⠀⠁⠀⠄
⠁⠀⠀⠈⢀⠀⠁⠀⢀⠀⠁⡀⠈⠀⠐⠀⢀⠠⠀⠂⠈⠀⠐⠀⢀⠠⠀⠂⠈⠀⠐⠀⢀⠠⠀⠂⠈⠀⡼⠈⠌⠌⠌⢼⠀⡇⠀⠁⠈⠀⡀
⠄⠂⠁⠈⠀⠀⠐⠈⠀⠀⡀⢀⠀⠁⢀⠐⠀⠀⢀⠠⠐⠈⠀⢀⠀⠀⡀⠠⠐⠈⠀⢀⠀⠀⡀⠠⠐⢰⢑⠨⠀⠅⡡⡏⢸⠁⠀⠐⠈⠀⠀
⢀⠀⠄⠀⠂⠈⠀⠀⠄⠂⠀⠀⢀⠈⠀⠀⢀⢐⣀⣠⣤⣤⣀⣀⠄⠂⠀⠀⡀⠀⠄⠀⡀⠂⠀⠀⠀⡞⡐⢄⠡⢁⢰⠅⡏⠀⠀⠂⠀⠐⠀
⠀⢀⠠⠀⠂⠀⠈⠀⡀⠀⠄⠈⠀⢀⣤⡾⡯⣟⡽⡶⡶⡮⡯⣭⢟⣿⣲⣤⡀⠀⠄⠀⡀⠀⡀⠁⢨⢃⢂⠅⡂⡂⡞⣸⠀⠀⠂⠀⠁⠀⠂
⢀⠀⠀⡀⠠⠈⠀⠁⠀⠀⠄⢐⣼⢟⣗⡯⠛⠚⠚⠻⣽⢽⣝⣗⣟⣞⡾⠾⠿⣦⡀⠠⠀⢀⠀⠀⡞⡐⡐⢌⠐⢬⠡⡇⠀⠐⠀⠁⠀⠁⢀
⠀⠠⠀⠀⡀⠀⠄⠂⠈⠀⣴⡿⣽⡽⠁⠀⠀⠄⠠⠀⠈⠻⣞⣞⣮⢏⠀⠀⡀⠀⠹⣄⠀⡀⠀⢸⢑⠐⠌⠄⢅⡏⣸⠀⠀⠄⠂⠀⠁⠠⠀
⡀⠄⠀⠂⠀⠀⠄⠀⠄⣾⣻⣺⡽⠀⠀⡀⠁⠀⠄⠐⠀⡀⢿⣞⣾⠀⠀⠂⡀⡐⠀⠈⢦⠀⢀⡏⡂⠅⢅⠅⣱⢁⡇⠀⢀⠀⠄⠐⠈⠀⠀
⠀⢀⠠⠐⠈⠀⠀⠄⣼⣻⣺⣺⡇⠀⠢⣾⣿⣿⣷⠆⢠⠤⢜⢗⠻⡲⢥⠺⠿⠿⠿⠃⠈⣇⢸⡐⠌⠌⠔⢐⡎⣸⠀⠀⡀⠀⡀⠠⠀⠐⠀
⠐⠀⠀⠀⡀⠐⠀⢰⣟⣞⣞⣞⡇⠀⢀⠀⠠⠐⠀⠀⠘⠚⠒⠒⠓⠊⠁⡀⠀⡀⠀⠄⠀⠸⣧⣂⡅⠅⠅⡴⡁⡎⠀⠀⡀⠀⡀⠀⠠⠐⠀
⠐⠀⢀⠁⠀⠀⠄⣟⣗⣗⣗⡯⣷⡀⡀⠄⠀⠄⠐⠈⠀⡀⠂⠈⠀⠈⢀⠀⠠⠀⠐⠀⠀⠄⣗⠴⡩⡙⡓⢷⠼⠀⠀⠂⠀⢀⠀⠄⠂⠀⠀
⠠⠐⠀⠀⠐⠀⢐⣿⣺⡺⣮⣻⣺⢽⣳⢶⢶⡶⠀⠐⠀⢀⠀⠂⠁⠈⠀⠀⠄⠐⠀⠈⠀⠀⢱⠹⡨⡮⡮⠋⠀⠀⠐⠀⠈⠀⠀⠀⡀⠀⠁
⠠⠀⠀⠂⠀⠂⢸⣗⣗⣯⢗⣗⣯⣻⣺⡽⣻⠁⠠⠐⠈⠀⠀⠄⠂⠈⠀⠐⠀⠠⠈⠀⠁⠠⢸⢱⢸⢕⠇⠀⠂⠁⠀⠂⠁⠀⠈⠀⠀⡀⠁
⠠⠀⠂⠀⠁⢀⢸⣗⣯⣷⢵⣗⣗⣗⣿⢽⠇⠐⠀⠀⠄⠐⠀⠠⠀⠂⠁⢀⠈⠀⡀⠂⠁⠀⢸⢌⡯⡞⠀⠀⠄⠐⠀⠠⠐⠈⠀⠈⠀⠀⡀
⠀⡀⠄⠂⠁⠀⢸⣗⣗⡿⣞⣞⡞⣾⢯⣿⠀⠐⠈⠀⠠⠐⠈⠀⠀⠄⠂⠀⡀⠂⠀⡀⠐⠈⡞⣼⢪⠃⠀⠠⠀⠠⠐⠀⠀⠠⠐⠈⠀⡀⠀
⠁⠀⠀⠀⢠⣴⢾⡳⣗⢿⢽⢷⣻⢯⣗⡯⠀⡀⠂⠈⠀⠀⠄⠂⠁⠀⡀⠂⠀⠠⠀⡀⠄⢀⢯⣓⡏⠀⠀⠂⠀⠄⠀⠠⠈⠀⠀⡀⢀⠀⠠
⠁⢀⠈⠀⢿⣳⢯⢯⢯⢯⢯⣻⣺⣳⣳⣟⠀⠀⡀⠂⠁⠀⠄⠀⠐⠀⢀⠀⠂⠀⠄⠀⢀⣜⣟⡼⠀⠀⠁⠀⠂⠀⠐⠀⢀⠐⠀⠀⢀⠀⠄
⠠⠀⠀⠄⠈⠻⣯⡿⣽⢽⢽⣺⢞⣞⣞⣾⣀⣠⣀⣀⠄⠁⢀⠈⢀⠈⠀⠀⠄⠁⢀⡴⡚⣝⠊⠀⠠⠀⠁⠀⠂⠈⠀⠠⠀⢀⠠⠈⠀⠀⢀
⠀⡀⠄⠀⠄⠀⠀⠈⠙⠛⠛⠫⠿⠾⣞⠫⡨⠢⡒⢌⢕⡄⢄⠠⣀⣄⣨⠤⠦⣞⣕⡽⠒⠚⠀⠀⠂⠀⠈⢀⠀⠂⠈⠀⢀⠀⠀⢀⠠⠈⠀
⠀⠀⢀⠠⠀⠈⠀⠁⢀⠠⠀⠠⠀⠸⠦⠇⠓⠳⠼⠒⠙⠉⠈⠉⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⠠⠐⠀⠈⠀⡀⠀⠄⠂⠈⠀⠀⠈⠀⠀⠀⠀
⠈⠀⠀⢀⠀⠄⠁⢀⠀⢀⠀⠄⠀⡀⠀⡀⠄⠀⢀⠀⠠⠐⠀⠂⠀⠂⠐⠀⠂⠐⠀⢀⠁⠀⠀⠀⡀⠈⠀⠀⡀⢀⠠⠀⠐⠈⠀⠐⠀⠁⠀
EOF
    echo -e "${RESET}"
}

# Function to display system information
display_sys_info() {
    echo -e "${GREEN}Welcome, ${CYAN}$USER${GREEN}! Today is ${YELLOW}$(date +"%A, %B %d, %Y")${GREEN}.${RESET}"
    echo -e "${GREEN}Current Time: ${YELLOW}$(date +"%T")${RESET}"
    echo -e "${GREEN}System Uptime: ${YELLOW}$(uptime -p)${RESET}"
    echo -e "${GREEN}Kernel Version: ${YELLOW}$(uname -r)${RESET}"
    echo -e "${GREEN}Current Directory: ${YELLOW}$(pwd)${RESET}"
}

# Function to display CPU and Memory usage
display_resource_usage() {
    # Get CPU usage
    local cpu_usage
    cpu_usage=$(top -bn1 | grep "Cpu(s)" | \
                sed "s/.*, *\([0-9.]*\)%* id.*/\1/" | \
                awk '{print 100 - $1"%"}')

    # Get Memory usage
    local mem_total mem_used mem_free mem_usage
    mem_total=$(free -m | awk '/Mem:/ {print $2}')
    mem_used=$(free -m | awk '/Mem:/ {print $3}')
    mem_free=$(free -m | awk '/Mem:/ {print $4}')
    mem_usage=$(awk "BEGIN {printf \"%.2f\", ($mem_used/$mem_total)*100}")

    echo -e "${GREEN}CPU Usage: ${YELLOW}$cpu_usage${RESET}"
    echo -e "${GREEN}Memory Usage: ${YELLOW}$mem_usage% (${mem_used}MB / ${mem_total}MB)${RESET}"
}

# Function to display a random quote (Star Wars and Programming)
display_quote() {
    local quotes=(
    "“Talk is cheap. Show me the code.” – Linus Torvalds",
    "“It works on my machine.” – Every Developer, ever",
    "“There are 10 types of people in the world: those who understand binary, and those who don’t.”",
    "“Programming is like writing a book... except if you miss a single comma on page 126 the whole thing makes no sense.”",
    "“I have not failed. I've just found 10,000 ways that won't work.\" – Thomas Edison (probably debugging JavaScript)"",
    ""It's not a bug – it's an undocumented feature!”",
    "“Why do Java developers wear glasses? Because they can't C#.”",
    "“In theory, there is no difference between theory and practice. But, in practice, there is.” – Jan L.A. van de Snepscheut",
    "“There are only two hard things in Computer Science: cache invalidation, naming things, and off-by-one errors.” – Phil Karlton",
    "“Real programmers count from 0.”",
    "“A SQL query goes into a bar, walks up to two tables and asks: 'Can I join you?'”",
    "“A user interface is like a joke. If you have to explain it, it’s not that good.”",
    "“I’m not great at advice, but can I interest you in a sarcastic comment?” – Chandler Bing, probably to a junior dev",
    "“The best thing about a Boolean is that even if you are wrong, you are only off by a bit.”",
    "“Knock, knock.” “Who’s there?” “*long pause*... Java.”",
    "“When your hammer is C++, everything begins to look like a thumb.” – Steve Haflich",
    "“Debugging is like being the detective in a crime movie where you are also the murderer.”",
    "“I don’t always test my code, but when I do, I do it in production.”",
    "“To understand recursion, one must first understand recursion.”",
    "“If at first you don’t succeed; call it version 1.0”",
    "“Git commit -m 'fixed some bugs'” – the most repeated lie in programming history",
    "“Python: Because punching people is frowned upon.”",
    "“If brute force doesn’t solve your problems, then you aren’t using enough.”",
    "“Programming is 10% writing code and 90% figuring out why it isn’t working.”",
    "“Computers are fast; programmers keep it slow.”",
    "“The cloud is just someone else’s computer.”",
    "“Code never lies, comments sometimes do.”",
    "“Caffeine is my programming buddy. It never complains about spaghetti code.”",
    "“Do. Or do not. There is no try.” – Yoda",
    "“Never tell me the odds!” – Han Solo",
    "“Frak it!” – Starbuck, probably after a failed deployment",
    "“The needs of the many outweigh the needs of the few.” – Spock, when arguing about code refactoring",
    "“So say we all.” – Battlestar Galactica crew, after a successful code review",
    "“Fear is the path to the dark side. Fear leads to anger, anger leads to hate, hate leads to suffering.” – Yoda, warning developers about scope creep",
    "“I find your lack of faith disturbing.” – Darth Vader, when someone doubts your code will work",
    "“By your command.” – Cylons, after running a successful script",
    "“The Force will be with you, always.” – Obi-Wan Kenobi, when handing over documentation",
    "“Winter is coming.” – Eddard Stark, when production server load is about to spike",
    "“I am Groot.” – Groot, when trying to explain recursion",
    "“Make it so.” – Captain Picard, after merging a pull request",
    "“You have failed this city!” – Oliver Queen, when the build fails",
    "“This is the way.” – Mandalorian, when following coding standards",
    "“All your base are belong to us.” – Zero Wing, when your team takes over another department's project",
    "“Resistance is futile.” – The Borg, when your code review comments are ignored",
    "“Live long and prosper.” – Spock, after optimizing code for performance",
    "“With great power comes great responsibility.” – Uncle Ben, when committing to production",
    "“I’ll be back.” – Terminator, when your code crashes but you have a backup plan",
    "“The cake is a lie.” – Portal, when promises of an easy bug fix turn out to be false",
    "“Hasta la vista, baby.” – Terminator, after successfully deprecating old code",
    "“It’s a trap!” – Admiral Ackbar, when debugging circular dependencies",
    "“In the end, we’re all just nerds.” – Felicia Day",
    "“You shall not pass!” – Gandalf, when a junior dev tries to merge without a code review",
    "“I’m Mary Poppins, y’all!” – Yondu, after a successful code deploy that nobody expected to work",
    "“I am the one who knocks.” – Walter White, when force-pushing to the main branch",
    "“I love it when a plan comes together.” – Hannibal, when all unit tests pass",
    "“Yippee-ki-yay!” – John McClane, after squashing an elusive bug",
    "“That’s no moon.” – Obi-Wan Kenobi, after discovering a giant undocumented function",
    "“Shiny.” – Mal Reynolds, when the UI looks great after a deployment",
    "“I find your lack of documentation disturbing.” – Darth Vader",
    "“The Matrix has you.” – Morpheus, when explaining why debugging concurrency issues feels impossible",
    "“Why so serious?” – The Joker, after breaking production and laughing about it",
    "“Elementary, my dear Watson.” – Sherlock Holmes, when finding a simple fix to a tricky bug"
)
    # Get a random quote
    local quote=${quotes[$RANDOM % ${#quotes[@]}]}
    echo -e "${MAGENTA}\"$quote\"${RESET}"
}

# Function to display additional system info
display_additional_info() {
    echo -e "${CYAN}"
    echo "------------------------------"
    echo "OS: $(lsb_release -ds 2>/dev/null || uname -s)"
    echo "Host: $(hostname)"
    echo "Shell: $SHELL"
    echo "CPU Cores: $(nproc --all)"
    echo "Memory Total: $(free -m | awk '/Mem:/ {print $2" MB"}')"
    echo "Disk Usage: $(df -h / | awk 'NR==2 {print $5}') used of $(df -h / | awk 'NR==2 {print $2}')"
    echo "------------------------------"
    echo -e "${RESET}"
}

# Function to add a decorative separator
display_separator() {
    echo -e "${BOLD}${GREEN}========================================${RESET}\n"
}

# Execute the functions to display the MOTD
display_banner
display_sys_info
display_resource_usage
# display_additional_info unneeded as its a repeat of the previous info and because this is just local
display_quote
display_separator
