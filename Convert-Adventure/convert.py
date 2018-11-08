from tkinter import *
from tkinter import filedialog
import os
import json


def left(s, amount):
    return s[:amount]

def right(s, amount):
    return s[-amount:]

def mid(s, offset, amount):
    return s[offset-1:offset+amount-1]



line_list = []
line_num = 0
line_total = 0
line_count = 0
page_count = 0
page_num = 0
adventure = {}


# Select the input file:
file_path = filedialog.askopenfilename()
#file_path = 'C:/Users/dougk/Dropbox/Games/Retro RPG Text Adventure Engine/Assets/Adventure.md'


# open the file and read all of the lines into the line_list list.

with open(file_path) as fp:
    line_list = fp.readlines()
    #count = len(line_list)


# Figure out how many total pages and lines there are in the adventure file. The adventure file is a Markdown file with a *.md extension.
line_count = len(line_list)
for line in line_list:
    if left(line,1) == "#":
        # This line is a page title.
        page_count += 1
        #line_count += 1


# Set up the pages list of lists, there are page_count lists of line_count lists. i.e. pages[page][line]
    # I had to make the size big enough to fit everything and clean it up later, couldn't add to it on the fly for some reason.
pages = [[0 for x in range(line_count)] for y in range(page_count)]

# loop through each lines in line_list and store it in the appropriate pages[page][line] list.
page_num = -1
line_num = 0
for i in range(len(line_list)):
    current_line = line_list[i]
    #print("Current Line: ", current_line)
    if left(current_line, 1) == chr(10):
        # Don't do anything with blank lines. Blank lines start with a linefeed (chr(10) return in .md format
        pass
    elif left(current_line, 4) == "<!--":
        # Don't do anything with lines that start with a <!--, this indiates that the line is a comment line.
        #print("Current Line started with <")
        pass
    elif left(current_line, 1) == "#":
        #print("Current Line started with #")
        # This is a title line so store it in pages[0][0] for the first one.
        page_num += 1
        # Line Num has to start over at 0 when a new page starts.
        line_num = 0
        #print("Page Num is: ", str(page_num), " and line num is: ", str(line_num))
        pages[page_num][line_num] = current_line
        #print("Added Current Line to page[", str(page_num), "][", str(line_num), "]: ", pages[page_num][line_num])
        # Get ready for the next line.
        line_num += 1
    else:
        # the line is not a page heading, so it is just added to the list of lines.
        pages[page_num][line_num] = current_line
        #print("Added Current Line to page[", str(page_num), "][", str(line_num), "]: ", pages[page_num][line_num])
        # Get ready for the next line.
        line_num += 1

# Remove all of the extra items (this was because I had to make the lists too long)
for i in range(page_count):
    for j in range(pages[i].count(0)):
        pages[i].remove(0)






# Build and fill the dictionary
adventure = {}
adventure_page = {}

# Variables to be used in dictionary
page_ID = ""
page_title = ""
page_narrative = ""
page_choice = [4]
page_choice_goto = [4]
page_goto = ""

for i in range(len(pages)):
    
    # Here write it to the dictionary.
    if page_ID != "":
        # Here write it to the dictionary (before erasing the variables and starting over)
        adventure_page = {"title": page_title, "narrative": page_narrative}
        for x in range(len(page_choice)):
            choice_key_text = "choice" + str(x)
            adventure_page[choice_key_text] = page_choice[x]
        for x in range(len(page_choice_goto)):
            goto_choice_key_text = "choice-goto" + str(x)
            adventure_page[goto_choice_key_text] = page_choice_goto[x]
        adventure.update({page_ID:adventure_page})
        #adventure[page_ID].append(adventure_page)
        # Still need to get the page_choice and page_choice_goto into the dictionary.
        #print(adventure)
    # clear out everything for the new page.
    page_ID = ""
    page_title = ""
    page_narrative = ""
    page_choice = []
    page_choice_goto = []
    page_goto = ""
    for j in range(len(pages[i])):
        if left(pages[i][j], 1) == "#":
            # Break the title line into component parts page_ID and page_title
            title_line = pages[i][0]
            title_beg = title_line.find("_")
            page_ID = left(title_line,title_beg)
            page_ID = right(page_ID,len(page_ID)-2)
            page_title = right(title_line,len(title_line)-title_beg-1)
        elif left(pages[i][j], 1) == "*" and left(pages[i][j], 2) != "**":
            # This line is a choice, so we need to fill out the page_choice and page_choice_goto arrays
            choice_beg = pages[i][j].find("<!--")
            page_choice_text = left(pages[i][j], choice_beg)
            page_choice_text = right(page_choice_text, len(page_choice_text)-2)
            page_choice.append(page_choice_text)

            choice_beg = pages[i][j].find("_")
            page_choice_goto_text = right(pages[i][j], len(pages[i][j]) - choice_beg)
            page_choice_goto_text = right(page_choice_goto_text, len(page_choice_goto_text)-1)
            choice_beg = page_choice_goto_text.find("_")
            page_choice_goto_text = left(page_choice_goto_text, choice_beg)
            page_choice_goto.append(page_choice_goto_text)
        else:
            # This line is part of the narrative...add to the varible (rather than re-write it)
            page_narrative = page_narrative + chr(13) + chr(10) + pages[i][j]

    # Clean Up page_narrative because it starts with a page return and new line.
    page_narrative = right(page_narrative, len(page_narrative) - 2 )

# Do this one last time for the last page that has been loaded in.
adventure_page = {"title": page_title, "narrative": page_narrative}
for x in range(len(page_choice)):
    choice_key_text = "choice" + str(x)
    adventure_page[choice_key_text] = page_choice[x]
for x in range(len(page_choice_goto)):
    goto_choice_key_text = "choice-goto" + str(x)
    adventure_page[goto_choice_key_text] = page_choice_goto[x]
adventure.update({page_ID:adventure_page})


# Select the destination file:
file_path = filedialog.asksaveasfilename()

with open(file_path, "w") as outfile:
    json.dump(adventure, outfile)