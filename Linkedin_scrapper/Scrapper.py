import time
import random
import logging
from pathlib import Path
from selenium import webdriver
from selenium.webdriver.chrome.service import Service
from webdriver_manager.chrome import ChromeDriverManager
from bs4 import BeautifulSoup
import pandas as pd

# ---------------------------
# Configuration
# ---------------------------

OUT_DIR = Path("outputs")
OUT_DIR.mkdir(exist_ok=True)
OUT_CSV = OUT_DIR / "profiles.csv"
URLS_FILE = "urls.txt"
MAX_PROFILES = 20  # limit to 20 profiles as required

# Setup logging
logging.basicConfig(
    filename=OUT_DIR / "scraper.log",
    level=logging.INFO,
    format="%(asctime)s [%(levelname)s] %(message)s",
)
console = logging.StreamHandler()
console.setLevel(logging.INFO)
formatter = logging.Formatter("%(asctime)s [%(levelname)s] %(message)s")
console.setFormatter(formatter)
logging.getLogger().addHandler(console)

# ---------------------------
# Selenium Setup
# ---------------------------

def setup_driver():
    """Initialize Chrome WebDriver (headful) so user can manually log in."""
    options = webdriver.ChromeOptions()
    # Keep headful so user can manually log in:
    # options.add_argument("--headless=new")  # DO NOT enable headless for manual login
    options.add_argument("--disable-blink-features=AutomationControlled")
    options.add_argument("--no-sandbox")
    options.add_argument("--start-maximized")
    options.add_argument("--disable-gpu")
    driver = webdriver.Chrome(service=Service(ChromeDriverManager().install()), options=options)
    driver.set_page_load_timeout(60)
    return driver

# ---------------------------
# Utility / detection
# ---------------------------

def is_login_wall(html):
    """Detect if LinkedIn shows a login wall or restricted page."""
    text = html.lower()
    login_markers = [
        "sign in to view", "join linkedin to see", "please sign in",
        "sign in to continue", "you must be logged in", "join linkedin"
    ]
    return any(marker in text for marker in login_markers)

def check_logged_in(driver):
    """
    Very simple heuristic to check if user is logged in:
    - Try to open LinkedIn home and look for elements that exist when logged in.
    This is conservative: still ask user for manual confirmation.
    """
    try:
        driver.get("https://www.linkedin.com/feed/")
        time.sleep(2.5)
        html = driver.page_source.lower()
        # If feed page contains "feed" or "my network" etc, assume logged in.
        if "feed" in html and not is_login_wall(html):
            return True
    except Exception:
        pass
    return False

# ---------------------------
# HTML Parsing
# ---------------------------

def parse_profile(html):
    """Parse desired profile fields from the page HTML."""
    soup = BeautifulSoup(html, "lxml")

    def safe_text(sel):
        el = soup.select_one(sel)
        return el.get_text(strip=True) if el else ""

    name = safe_text("h1")
    # LinkedIn selectors can vary; we try a few fallbacks
    headline = safe_text(".text-body-medium") or safe_text(".pv-top-card--experience-list") or safe_text(".top-card-layout__headline")
    location = safe_text(".text-body-small") or safe_text(".pv-top-card--list-bullet") or safe_text(".top-card__subline-item")
    about = safe_text("#about") or safe_text(".pv-about__summary-text") or safe_text(".section__description")
    
    exp_title, exp_company = "", ""
    # attempt to get first experience block
    exp_block = soup.select_one(".pv-position-entity") or soup.select_one(".experience-item") or soup.select_one(".pv-entity__summary-info")
    if exp_block:
        title_el = exp_block.select_one("h3, .t-16, .pv-entity__summary-info h3")
        comp_el = exp_block.select_one("p, .t-14, .pv-entity__secondary-title")
        exp_title = title_el.get_text(strip=True) if title_el else ""
        exp_company = comp_el.get_text(strip=True) if comp_el else ""

    website = ""
    # look for contact/website link
    contact_link = soup.select_one(".pv-top-card--list-bullet a") or soup.select_one(".ci-web .pv-contact-info__ci-container a")
    if contact_link:
        website = contact_link.get("href", "")

    data = {
        "name": name,
        "headline": headline,
        "location": location,
        "about": about,
        "exp_title": exp_title,
        "exp_company": exp_company,
        "website": website,
    }
    return data

# ---------------------------
# Main Execution
# ---------------------------

def main():
    urls = [u.strip() for u in Path(URLS_FILE).read_text().splitlines() if u.strip()]
    if not urls:
        logging.error("No URLs found in urls.txt. Please add LinkedIn profile URLs (one per line).")
        return

    urls = urls[:MAX_PROFILES]  # limit to 20
    logging.info(f"Starting scraping for up to {len(urls)} URLs (max {MAX_PROFILES})")

    driver = setup_driver()

    # Step 1: Open LinkedIn and ask user to log in manually
    logging.info("Opening LinkedIn. Please sign in manually in the opened browser window.")
    driver.get("https://www.linkedin.com/login")
    # Give user time to login manually
    input("After you sign in manually in the browser window, press ENTER here to continue...")

    # Quick check if login likely succeeded
    if not check_logged_in(driver):
        logging.warning("Automated check did not detect a successful login. If you are logged in, you can continue; otherwise the scraper may hit login walls.")
        cont = input("Proceed anyway? (y/N): ").strip().lower()
        if cont != "y":
            logging.info("Exiting as requested.")
            driver.quit()
            return

    results = []
    success_count = 0
    skipped_count = 0
    error_count = 0

    for i, url in enumerate(urls, 1):
        logging.info(f"[{i}/{len(urls)}] Visiting: {url}")
        try:
            driver.get(url)
            time.sleep(random.uniform(2.5, 4.5))  # let page load

            html = driver.page_source

            # If still shows a login wall despite manual login, log and skip
            if is_login_wall(html):
                logging.warning(f"Login wall detected for {url}. Skipping.")
                results.append({"url": url, "error": "login_wall_detected"})
                skipped_count += 1
                continue

            data = parse_profile(html)
            data["url"] = url
            results.append(data)
            success_count += 1
            logging.info(f"Scraped: {data}")
            time.sleep(random.uniform(1.5, 4.0))  # polite wait

        except Exception as e:
            logging.error(f"Error scraping {url}: {e}")
            results.append({
                "url": url, "name": "", "headline": "", "location": "",
                "about": "", "exp_title": "", "exp_company": "",
                "website": "", "error": str(e)
            })
            error_count += 1
            time.sleep(random.uniform(3.0, 6.0))

    driver.quit()

    # Save results
    df = pd.DataFrame(results)
    df.to_csv(OUT_CSV, index=False)
    logging.info(f"Saved {len(df)} rows to {OUT_CSV}")
    logging.info("Summary:")
    logging.info(f"  Successful: {success_count}")
    logging.info(f"  Skipped (login wall): {skipped_count}")
    logging.info(f"  Errors: {error_count}")
    logging.info("Done")

if __name__ == "__main__":
    main()
