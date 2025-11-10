# 🕵️‍♂️ LinkedIn Profile Scraper

This project is part of the **AeroLeads AI Developer Assignment**.  
It demonstrates web scraping, data extraction, and CSV generation using **Python**, **Selenium**, and **BeautifulSoup**.  

> ⚠️ **Note:** This scraper only works with *publicly accessible* LinkedIn profile pages or other websites containing LinkedIn data.  
> It does **not** bypass logins, CAPTCHAs, or restricted pages, in compliance with LinkedIn’s [Terms of Service](https://www.linkedin.com/legal/user-agreement).

---

## 📋 Project Objective

The goal of this task is to:
1. Scrape 20 random LinkedIn (or equivalent public) profiles.  
2. Extract useful profile information such as:
   - Name  
   - Headline / Job Title  
   - Location  
   - About / Summary  
   - Top Experience (title, company)  
   - Public website link (if available)  
3. Save the extracted data into a CSV file.

---

## 🧠 Approach

Since most LinkedIn profiles require login, this project focuses on **scraping publicly available data** using:
- `Selenium` to load and render web pages.
- `BeautifulSoup` to parse HTML content.
- `pandas` to store the structured data as a CSV file.

If a LinkedIn page is blocked by a login prompt, the scraper gracefully skips it and moves to the next URL.

---

## 🧰 Tech Stack

- **Language:** Python 3.10+  
- **Libraries:**
  - `selenium`
  - `webdriver-manager`
  - `beautifulsoup4`
  - `pandas`
  - `lxml`
- **Browser:** Google Chrome (via ChromeDriver)

---

## 📁 Folder Structure

linkedin_scraper/
│
├── scraper.py # Main scraping script
├── urls.txt # List of 20 LinkedIn profile URLs
├── outputs/
│ └── profiles.csv # Extracted data output
└── README.md # Documentation (this file)


---

## 🚀 How to Run the Scraper

### 1️⃣ Clone the Repository
```bash
git clone https://github.com/yourusername/aeroleads-ai-assignment.git
cd aeroleads-ai-assignment/linkedin_scraper

2️⃣ Install Dependencies
pip install -r requirements.txt


or manually:

pip install selenium webdriver-manager beautifulsoup4 pandas lxml

3️⃣ Add URLs

All 20 LinkedIn profile URLs are listed in urls.txt:

https://in.linkedin.com/in/powerfist01
https://in.linkedin.com/in/mjmadhu
https://in.linkedin.com/in/ritesh-kumar-sinha-897735101
https://in.linkedin.com/in/abhishree-sharma-63090814a
https://in.linkedin.com/in/shivam-garg-676686217
https://in.linkedin.com/in/thevipulvats
https://in.linkedin.com/in/developerrahul
https://in.linkedin.com/in/rajendrasingh9554043123
https://in.linkedin.com/in/rahsin11
https://in.linkedin.com/in/saurabh-patel-41269a14b
https://in.linkedin.com/in/orendrasingh
https://in.linkedin.com/in/jaskaran-singh-9b3937169
https://in.linkedin.com/in/lakhvir-singh-3158291b3
https://in.linkedin.com/in/shanu-mittal-ba4083104
https://in.linkedin.com/in/pushpraj-patel-4006ba18a
https://in.linkedin.com/in/kannan-india-32359a14a
https://in.linkedin.com/in/pankaj-patel-770647200
https://in.linkedin.com/in/devender-choudhary-4621bb7b
https://in.linkedin.com/in/imdeepraj
https://in.linkedin.com/in/mukesh-hembrom-a6a702134


You can modify this file if you want to test with different public profiles.

4️⃣ Run the Scraper
python scraper.py


The script will:

Open each LinkedIn URL in Chrome

Extract visible details (if publicly available)

Save the data into outputs/profiles.csv