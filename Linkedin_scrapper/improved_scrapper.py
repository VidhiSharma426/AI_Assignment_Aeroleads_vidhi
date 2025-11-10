import time
import random
import logging
from pathlib import Path
from selenium import webdriver
from selenium.webdriver.chrome.service import Service
from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
from webdriver_manager.chrome import ChromeDriverManager
from bs4 import BeautifulSoup
import pandas as pd

# ---------------------------
# Configuration
# ---------------------------

OUT_DIR = Path("outputs")
OUT_DIR.mkdir(exist_ok=True)
OUT_CSV = OUT_DIR / "improved_profiles.csv"
URLS_FILE = "urls.txt"
MAX_PROFILES = 20

# Setup logging
logging.basicConfig(
    filename=OUT_DIR / "improved_scraper.log",
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
    """Initialize Chrome WebDriver with optimized settings."""
    options = webdriver.ChromeOptions()
    options.add_argument("--disable-blink-features=AutomationControlled")
    options.add_argument("--no-sandbox")
    options.add_argument("--start-maximized")
    options.add_argument("--disable-gpu")
    options.add_argument("--disable-dev-shm-usage")
    # Add user agent to look more natural
    options.add_argument("--user-agent=Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36")
    
    driver = webdriver.Chrome(service=Service(ChromeDriverManager().install()), options=options)
    driver.set_page_load_timeout(60)
    return driver

# ---------------------------
# Utility Functions
# ---------------------------

def is_login_wall(driver):
    """Detect if LinkedIn shows a login wall or restricted page."""
    try:
        html = driver.page_source.lower()
        login_markers = [
            "sign in to view", "join linkedin to see", "please sign in",
            "sign in to continue", "you must be logged in", "join linkedin"
        ]
        return any(marker in html for marker in login_markers)
    except:
        return True

def wait_for_element(driver, selector, timeout=10):
    """Wait for element to be present and return it."""
    try:
        element = WebDriverWait(driver, timeout).until(
            EC.presence_of_element_located((By.CSS_SELECTOR, selector))
        )
        return element
    except:
        return None

def safe_get_text(soup, selectors):
    """Try multiple selectors and return first successful text extraction."""
    if isinstance(selectors, str):
        selectors = [selectors]
    
    for selector in selectors:
        try:
            element = soup.select_one(selector)
            if element:
                text = element.get_text(strip=True)
                if text:
                    return text
        except:
            continue
    return ""

# ---------------------------
# Enhanced Profile Parsing
# ---------------------------

def extract_name(soup):
    """Extract profile name using multiple strategies."""
    name_selectors = [
        'h1.text-heading-xlarge',
        'h1.pv-text-details__left-panel',
        'h1',
        '.pv-top-card--list h1',
        '.text-heading-xlarge',
        '.pv-text-details__left-panel h1'
    ]
    return safe_get_text(soup, name_selectors)

def extract_headline(soup):
    """Extract profile headline/current position."""
    headline_selectors = [
        '.text-body-medium.break-words',
        '.pv-text-details__left-panel .text-body-medium',
        '.text-body-medium',
        '.pv-top-card--experience-list-summary',
        '.top-card-layout__headline',
        '.pv-shared-text-with-see-more .break-words'
    ]
    return safe_get_text(soup, headline_selectors)

def extract_about(soup):
    """Enhanced about section extraction with multiple comprehensive strategies."""
    import re
    
    logging.info("🔍 Attempting comprehensive about extraction...")
    
    # Strategy 1: Direct ID-based approach
    about_element = soup.find(id='about')
    if about_element:
        logging.info("   ✅ Found #about element")
        
        # Look for content in various positions relative to about element
        candidates = [
            about_element.find_next_sibling(),
            about_element.parent.find_next_sibling() if about_element.parent else None,
            about_element.find_next(['div', 'section'])
        ]
        
        for i, candidate in enumerate(candidates):
            if candidate:
                text = candidate.get_text(strip=True)
                if len(text) > 50 and not text.lower().startswith(('experience', 'education', 'skills')):
                    logging.info(f"   ✅ Found about content via ID strategy {i}")
                    return text
    
    # Strategy 2: Modern LinkedIn selectors (2023-2024)
    modern_selectors = [
        'div[data-generated-suggestion-target] .break-words',
        '.pv-shared-text-with-see-more .break-words',
        '.core-section-container__content .break-words',
        'section[data-section="about"] .break-words',
        '.artdeco-card .break-words',
        '.scaffold-layout__detail .break-words',
        '#about ~ * .break-words',
        '#about + div .break-words'
    ]
    
    for selector in modern_selectors:
        elements = soup.select(selector)
        for element in elements:
            text = element.get_text(strip=True)
            if len(text) > 100:
                # Filter out non-about content
                if not any(skip in text.lower()[:50] for skip in ['experience at', 'education', 'skills', 'see all activity']):
                    logging.info(f"   ✅ Found about content via selector: {selector}")
                    return text
    
    # Strategy 3: Section-based comprehensive search
    sections = soup.find_all(['section', 'div'])
    
    for i, section in enumerate(sections):
        section_html = str(section).lower()
        
        if 'about' in section_html:
            # Look for substantial text in current and next sections
            for j in range(3):
                check_section = sections[i + j] if i + j < len(sections) else None
                if check_section:
                    text = check_section.get_text(strip=True)
                    if (len(text) > 100 and 
                        not any(skip in text.lower() for skip in ['experience', 'education', 'skills', 'activity', 'recommendations']) and
                        not re.match(r'^(about|activity|education|experience)$', text.lower().strip())):
                        logging.info("   ✅ Found about content via section search")
                        return text
    
    # Strategy 4: Text content analysis with scoring
    all_divs = soup.find_all(['div', 'span', 'p'])
    text_candidates = []
    
    for div in all_divs:
        text = div.get_text(strip=True)
        if len(text) > 150:
            parent_html = str(div.parent).lower() if div.parent else ""
            
            # Scoring system
            score = 0
            if 'about' in parent_html: score += 3
            if 'summary' in parent_html: score += 2
            if len(text) > 300: score += 1
            
            # Negative indicators
            if any(word in text.lower()[:100] for word in ['experience at', 'currently working']):
                score -= 3
            if any(word in text.lower() for word in ['education', 'university', 'degree']):
                score -= 2
            if text.lower().startswith(('experience', 'education', 'skills')):
                score -= 3
            
            if score > 0:
                text_candidates.append((score, text))
    
    # Return best scored candidate
    if text_candidates:
        text_candidates.sort(key=lambda x: x[0], reverse=True)
        score, text = text_candidates[0]
        logging.info(f"   ✅ Found about content via text analysis (score: {score})")
        return text
    
    # Strategy 5: Fallback - biographical content detection
    bio_indicators = ['passionate', 'experienced', 'professional', 'dedicated', 'skilled',
                     'background', 'expertise', 'specializing', 'focus', 'career']
    
    all_text_elements = soup.find_all(string=True)
    for element in all_text_elements:
        if hasattr(element, 'parent') and element.parent:
            text = element.strip()
            if len(text) > 200:
                bio_score = sum(1 for indicator in bio_indicators if indicator in text.lower())
                if bio_score >= 2:
                    logging.info("   ✅ Found about content via biographical analysis")
                    return text
    
    logging.warning("   ❌ No about section found with any strategy")
    return ""

def extract_experience(soup):
    """Enhanced experience extraction with multiple comprehensive strategies."""
    import re
    
    logging.info("🔍 Attempting comprehensive experience extraction...")
    current_company = ""
    previous_company = ""
    companies = []
    
    # Strategy 1: Modern LinkedIn experience structure
    logging.info("   Strategy 1: Modern LinkedIn selectors...")
    modern_selectors = [
        '.pvs-list__paged-list-item',
        '.pvs-entity',
        '.artdeco-list__item',
        '.experience-item',
        'li[data-field="experience"]'
    ]
    
    experience_items = []
    for selector in modern_selectors:
        items = soup.select(selector)
        if items:
            logging.info(f"   ✅ Found {len(items)} items with selector: {selector}")
            experience_items = items
            break
    
    # Strategy 2: Find experience section first, then look for items
    if not experience_items:
        logging.info("   Strategy 2: Finding experience section...")
        exp_section = soup.find(id='experience')
        if exp_section:
            logging.info("   ✅ Found #experience section")
            # Look in parent containers for experience items
            parent = exp_section.parent
            while parent and len(parent.select('li, .pvs-list__paged-list-item')) == 0:
                parent = parent.parent
                if not parent or parent.name == 'body':
                    break
            
            if parent:
                experience_items = parent.select('li, .pvs-list__paged-list-item, .pvs-entity')
                logging.info(f"   ✅ Found {len(experience_items)} experience items in parent")
    
    # Strategy 3: Look for any list items with job/company patterns
    if not experience_items:
        logging.info("   Strategy 3: Pattern-based search...")
        all_list_items = soup.select('li, .pv-entity__summary-info')
        
        for item in all_list_items:
            text = item.get_text(strip=True).lower()
            # Check if this looks like an experience item
            if any(pattern in text for pattern in ['at ', 'company', 'inc', 'corp', 'ltd', 'llc', 'software', 'engineer', 'manager', 'director']):
                if len(text) > 30 and len(text) < 500:  # Reasonable length
                    experience_items.append(item)
        
        logging.info(f"   ✅ Found {len(experience_items)} items via pattern search")
    
    # Extract companies from experience items
    if experience_items:
        logging.info(f"   Processing {len(experience_items)} experience items...")
        
        for i, item in enumerate(experience_items[:10]):  # Check first 10 items
            logging.info(f"   Processing experience item {i+1}...")
            
            # Multiple strategies to extract company name
            company_name = ""
            
            # Strategy A: Specific LinkedIn selectors
            company_selectors = [
                '.t-14.t-normal span[aria-hidden="true"]',
                '.pvs-entity__caption-wrapper',
                '.pv-entity__secondary-title',
                '.t-14.t-normal',
                'span.t-14',
                '.visually-hidden',
                '[data-field="company"]'
            ]
            
            for selector in company_selectors:
                elem = item.select_one(selector)
                if elem:
                    company_text = elem.get_text(strip=True)
                    if company_text and not company_text.lower().startswith(('experience', 'education', 'skills')):
                        company_name = company_text
                        logging.info(f"     Found company via selector {selector}: {company_name}")
                        break
            
            # Strategy B: Text pattern extraction
            if not company_name:
                item_text = item.get_text(strip=True)
                
                # Look for "at Company" pattern
                at_match = re.search(r'\bat\s+([A-Z][A-Za-z\s&.,\-]+?)(?:\s*[·•]|\s*$|\s*\n)', item_text)
                if at_match:
                    company_name = at_match.group(1).strip()
                    logging.info(f"     Found company via 'at' pattern: {company_name}")
                
                # Look for company name in second line/span
                if not company_name:
                    lines = [line.strip() for line in item_text.split('\n') if line.strip()]
                    if len(lines) >= 2:
                        potential_company = lines[1]
                        # Filter out non-company text
                        if not any(word in potential_company.lower() for word in ['full-time', 'part-time', 'months', 'years', 'present']):
                            company_name = potential_company
                            logging.info(f"     Found company via line extraction: {company_name}")
            
            # Strategy C: Look for spans with company-like text
            if not company_name:
                spans = item.select('span')
                for span in spans:
                    span_text = span.get_text(strip=True)
                    if (len(span_text) > 3 and len(span_text) < 50 and 
                        any(indicator in span_text for indicator in ['Inc', 'Corp', 'LLC', 'Ltd', 'Company', 'Technologies', 'Solutions']) and
                        not any(skip in span_text.lower() for skip in ['full-time', 'part-time', 'experience'])):
                        company_name = span_text
                        logging.info(f"     Found company via span analysis: {company_name}")
                        break
            
            # Clean and validate company name
            if company_name:
                # Clean up common suffixes and prefixes
                company_clean = re.sub(r'\s*[·•]\s*.*$', '', company_name)  # Remove everything after bullet
                company_clean = re.sub(r'\s*-\s*.*$', '', company_clean)    # Remove everything after dash
                company_clean = company_clean.strip()
                
                # Validate it looks like a company name
                if (len(company_clean) > 2 and 
                    not company_clean.lower() in ['experience', 'education', 'skills', 'about'] and
                    not company_clean.isdigit() and
                    company_clean not in companies):
                    
                    companies.append(company_clean)
                    logging.info(f"   ✅ Added company: {company_clean}")
                    
                    if len(companies) >= 2:  # We have enough companies
                        break
    
    # Strategy 4: Fallback - text mining for company patterns
    if len(companies) < 2:
        logging.info("   Strategy 4: Text mining fallback...")
        full_text = soup.get_text()
        
        # Look for "at CompanyName" patterns
        company_patterns = [
            r'\bat\s+([A-Z][A-Za-z\s&.,\-]+?)(?:\s+[·•]|\s*\n|\s*-|\s*$)',
            r'([A-Z][A-Za-z\s&]+(?:Inc|Corp|LLC|Ltd|Company|Technologies|Solutions))',
        ]
        
        for pattern in company_patterns:
            matches = re.findall(pattern, full_text)
            for match in matches:
                clean_match = match.strip()
                if (len(clean_match) > 3 and clean_match not in companies and
                    not any(skip in clean_match.lower() for skip in ['experience at', 'education at', 'university'])):
                    companies.append(clean_match)
                    logging.info(f"   ✅ Added company via text mining: {clean_match}")
                    if len(companies) >= 2:
                        break
            if len(companies) >= 2:
                break
    
    # Assign current and previous companies
    if len(companies) >= 1:
        current_company = companies[0]
        logging.info(f"   Current company: {current_company}")
    if len(companies) >= 2:
        previous_company = companies[1]
        logging.info(f"   Previous company: {previous_company}")
    
    if not current_company and not previous_company:
        logging.warning("   ❌ No companies found with any strategy")
    
    return current_company, previous_company

def parse_profile_enhanced(html):
    """Enhanced profile parsing with better selectors."""
    soup = BeautifulSoup(html, "lxml")
    
    # Extract all required fields
    name = extract_name(soup)
    headline = extract_headline(soup)
    about = extract_about(soup)
    current_company, previous_company = extract_experience(soup)
    
    data = {
        "name": name,
        "headline": headline,
        "about": about,
        "current_company": current_company,
        "previous_company": previous_company,
    }
    
    return data

# ---------------------------
# Main Execution
# ---------------------------

def save_to_csv_incremental(data, is_first_row=False):
    """Save data to CSV incrementally - append each row as it's scraped."""
    try:
        df = pd.DataFrame([data])
        
        if is_first_row:
            # Create new file with headers
            df.to_csv(OUT_CSV, index=False, mode='w')
            logging.info(f"📝 Created new CSV file: {OUT_CSV}")
        else:
            # Append to existing file without headers
            df.to_csv(OUT_CSV, index=False, mode='a', header=False)
        
        logging.info(f"💾 Saved data for: {data.get('name', 'Unknown')} to CSV")
        return True
    except Exception as e:
        logging.error(f"❌ Error saving to CSV: {e}")
        return False

def main():
    """Main scraping function with incremental CSV saving."""
    # Load URLs
    urls = [u.strip() for u in Path(URLS_FILE).read_text().splitlines() if u.strip()]
    if not urls:
        logging.error("No URLs found in urls.txt. Please add LinkedIn profile URLs (one per line).")
        return

    urls = urls[:MAX_PROFILES]  # Limit to 20 profiles
    logging.info(f"Starting enhanced scraping for {len(urls)} LinkedIn profiles")
    logging.info(f"📄 Results will be saved incrementally to: {OUT_CSV}")

    driver = setup_driver()
    
    try:
        # Step 1: Manual login
        logging.info("Opening LinkedIn login page. Please sign in manually.")
        driver.get("https://www.linkedin.com/login")
        input("After signing in manually in the browser, press ENTER to continue...")
        
        # Quick verification
        driver.get("https://www.linkedin.com/feed/")
        time.sleep(3)
        
        if is_login_wall(driver):
            logging.warning("Login verification failed. Proceeding anyway...")
            cont = input("Continue scraping? (y/N): ").strip().lower()
            if cont != "y":
                return
        else:
            logging.info("Login verification successful!")
        
        # Step 2: Scrape profiles with incremental saving
        success_count = 0
        error_count = 0
        first_row = True
        
        for i, url in enumerate(urls, 1):
            logging.info(f"[{i}/{len(urls)}] Processing: {url}")
            
            try:
                # Navigate to profile
                driver.get(url)
                time.sleep(random.uniform(3, 5))  # Wait for page load
                
                # Check for login wall
                if is_login_wall(driver):
                    logging.warning(f"Login wall detected for {url}. Skipping.")
                    data = {
                        "url": url,
                        "name": "", "headline": "", "about": "",
                        "current_company": "", "previous_company": "",
                        "status": "login_wall",
                        "scraped_at": pd.Timestamp.now().strftime("%Y-%m-%d %H:%M:%S")
                    }
                    save_to_csv_incremental(data, is_first_row=first_row)
                    first_row = False
                    error_count += 1
                    continue
                
                # Wait a bit more for dynamic content
                time.sleep(2)
                
                # Parse profile
                html = driver.page_source
                data = parse_profile_enhanced(html)
                data["url"] = url
                data["status"] = "success"
                data["scraped_at"] = pd.Timestamp.now().strftime("%Y-%m-%d %H:%M:%S")
                
                # Save immediately to CSV
                save_to_csv_incremental(data, is_first_row=first_row)
                first_row = False
                
                success_count += 1
                
                logging.info(f"✅ Scraped & Saved: {data['name']} | {data['headline'][:50]}...")
                
                # Show current progress
                total_processed = success_count + error_count
                print(f"📊 Progress: {total_processed}/{len(urls)} | ✅ Success: {success_count} | ❌ Failed: {error_count}")
                
                # Polite delay between requests
                time.sleep(random.uniform(2, 4))
                
            except Exception as e:
                logging.error(f"❌ Error scraping {url}: {e}")
                error_data = {
                    "url": url,
                    "name": "", "headline": "", "about": "",
                    "current_company": "", "previous_company": "",
                    "status": f"error: {str(e)[:100]}",  # Limit error message length
                    "scraped_at": pd.Timestamp.now().strftime("%Y-%m-%d %H:%M:%S")
                }
                save_to_csv_incremental(error_data, is_first_row=first_row)
                first_row = False
                error_count += 1
                time.sleep(random.uniform(3, 6))
        
    finally:
        driver.quit()
    
    # Step 3: Final summary
    total_processed = success_count + error_count
    
    logging.info(f"🎉 Scraping completed!")
    logging.info(f"   Total profiles processed: {total_processed}")
    logging.info(f"   ✅ Successful: {success_count}")
    logging.info(f"   ❌ Failed: {error_count}")
    logging.info(f"   📄 Results saved to: {OUT_CSV}")
    
    # Display summary of recent successful scrapes from CSV
    try:
        df = pd.read_csv(OUT_CSV)
        successful_df = df[df['status'] == 'success']
        
        if not successful_df.empty:
            print(f"\n📋 Sample of scraped data ({len(successful_df)} successful profiles):")
            print("=" * 80)
            for _, row in successful_df.tail(3).iterrows():  # Show last 3 successful
                print(f"✅ {row['name']}")
                print(f"   Headline: {row['headline'][:60]}...")
                print(f"   Current Company: {row['current_company']}")
                print(f"   Previous Company: {row['previous_company']}")
                print(f"   Scraped: {row['scraped_at']}")
                print("-" * 50)
        
        print(f"\n💾 Complete data available in: {OUT_CSV}")
        
    except Exception as e:
        logging.error(f"Error reading final CSV summary: {e}")

if __name__ == "__main__":
    main()