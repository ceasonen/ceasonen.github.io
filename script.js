/**
 * Academic Portfolio - Single Page Application
 * Professional academic portfolio with smooth navigation and animations
 */

// Global variables
let currentSection = 'about';
let isAnimating = false;

// Initialize the application
document.addEventListener('DOMContentLoaded', function() {
    console.log('Academic Portfolio initialized');
    
    // Initialize Lucide icons
    if (typeof lucide !== 'undefined') {
        lucide.createIcons();
    }
    
    // Setup navigation
    setupNavigation();
    
    // Setup smooth scrolling
    setupSmoothScrolling();
    
    // Setup responsive behavior
    setupResponsiveBehavior();
    
    // Initialize animations
    initializeAnimations();
    
    console.log('Portfolio setup complete');
});

/**
 * Setup navigation functionality
 */
function setupNavigation() {
    const navLinks = document.querySelectorAll('.nav-link');
    const contentSections = document.querySelectorAll('.content-section');
    
    navLinks.forEach(link => {
        link.addEventListener('click', function(e) {
            e.preventDefault();
            
            if (isAnimating) return;
            
            const targetSection = this.getAttribute('data-section');
            
            if (targetSection && targetSection !== currentSection) {
                navigateToSection(targetSection);
            }
        });
    });
    
    // Handle browser back/forward buttons
    window.addEventListener('popstate', function(e) {
        const section = e.state ? e.state.section : 'about';
        navigateToSection(section, false);
    });
}

/**
 * Navigate to a specific section with animation
 * @param {string} sectionId - The ID of the section to navigate to
 * @param {boolean} updateHistory - Whether to update browser history
 */
function navigateToSection(sectionId, updateHistory = true) {
    if (isAnimating) return;
    
    isAnimating = true;
    
    const targetSection = document.getElementById(sectionId);
    const currentSectionEl = document.querySelector('.content-section.active');
    const targetNavLink = document.querySelector(`[data-section="${sectionId}"]`);
    const currentNavLink = document.querySelector('.nav-link.active');
    
    if (!targetSection) {
        console.error(`Section ${sectionId} not found`);
        isAnimating = false;
        return;
    }
    
    // Update navigation state
    if (currentNavLink) {
        currentNavLink.classList.remove('active');
    }
    if (targetNavLink) {
        targetNavLink.classList.add('active');
    }
    
    // Hide current section with fade out animation
    if (currentSectionEl) {
        gsap.to(currentSectionEl, {
            opacity: 0,
            y: -20,
            duration: 0.3,
            ease: "power2.inOut",
            onComplete: () => {
                currentSectionEl.classList.remove('active');
                showTargetSection(targetSection);
            }
        });
    } else {
        showTargetSection(targetSection);
    }
    
    // Update browser history
    if (updateHistory) {
        const newUrl = `${window.location.pathname}#${sectionId}`;
        history.pushState({ section: sectionId }, '', newUrl);
    }
    
    currentSection = sectionId;
    
    // The icon observer will handle re-initialization automatically
}

/**
 * Show target section with fade in animation
 * @param {HTMLElement} targetSection - The section element to show
 */
function showTargetSection(targetSection) {
    targetSection.classList.add('active');
    
    // Reset GSAP properties
    gsap.set(targetSection, { opacity: 0, y: 20 });
    
    // Animate in
    gsap.to(targetSection, {
        opacity: 1,
        y: 0,
        duration: 0.5,
        ease: "power2.out",
        onComplete: () => {
            isAnimating = false;
            
            // Icon observer will handle re-initialization
            
            // Trigger entrance animations for content
            animateContentEntrance(targetSection);
        }
    });
}

/**
 * Animate content entrance for specific elements
 * @param {HTMLElement} section - The section to animate
 */
function animateContentEntrance(section) {
    // Animate cards with stagger effect
    const cards = section.querySelectorAll('.publication-card, .project-card, .honor-item, .contact-link');
    if (cards.length > 0) {
        gsap.fromTo(cards, {
            opacity: 0,
            y: 30,
            scale: 0.95
        }, {
            opacity: 1,
            y: 0,
            scale: 1,
            duration: 0.6,
            stagger: 0.1,
            ease: "back.out(1.7)",
            onComplete: () => {
                // Icon observer will handle re-initialization
            }
        });
    }
    
    // Animate skill pills
    const skillPills = section.querySelectorAll('.skill-pill');
    if (skillPills.length > 0) {
        gsap.fromTo(skillPills, {
            opacity: 0,
            scale: 0.8
        }, {
            opacity: 1,
            scale: 1,
            duration: 0.4,
            stagger: 0.05,
            ease: "back.out(1.7)"
        });
    }
    
    // Animate section title
    const sectionTitle = section.querySelector('.section-title');
    if (sectionTitle) {
        gsap.fromTo(sectionTitle, {
            opacity: 0,
            y: -20
        }, {
            opacity: 1,
            y: 0,
            duration: 0.6,
            ease: "power2.out"
        });
    }
}

/**
 * Setup smooth scrolling for anchor links
 */
function setupSmoothScrolling() {
    // Handle hash changes
    window.addEventListener('hashchange', function() {
        const hash = window.location.hash.substring(1);
        if (hash && hash !== currentSection) {
            navigateToSection(hash, false);
        }
    });
    
    // Handle initial hash
    const initialHash = window.location.hash.substring(1);
    if (initialHash && initialHash !== 'about') {
        navigateToSection(initialHash, false);
    }
}

/**
 * Setup responsive behavior
 */
function setupResponsiveBehavior() {
    let resizeTimeout;
    
    window.addEventListener('resize', function() {
        clearTimeout(resizeTimeout);
        resizeTimeout = setTimeout(handleResize, 250);
    });
    
    // Handle initial load
    handleResize();
}

/**
 * Handle window resize
 */
function handleResize() {
    const isMobile = window.innerWidth <= 1024;
    const navHub = document.querySelector('.nav-hub');
    const navLinks = document.querySelectorAll('.nav-link');
    
    if (isMobile) {
        // Mobile layout adjustments
        navHub.style.position = 'static';
        navHub.style.height = 'auto';
        
        // Make nav links horizontal scrollable
        navLinks.forEach(link => {
            link.style.whiteSpace = 'nowrap';
        });
    } else {
        // Desktop layout
        navHub.style.position = 'sticky';
        navHub.style.height = '100vh';
        
        // Reset nav links
        navLinks.forEach(link => {
            link.style.whiteSpace = 'normal';
        });
    }
}

// Icon functions removed - using inline SVG instead

/**
 * Initialize entrance animations
 */
function initializeAnimations() {
    // Animate initial content
    const activeSection = document.querySelector('.content-section.active');
    if (activeSection) {
        animateContentEntrance(activeSection);
    }
    
    // Setup intersection observer for scroll animations
    setupIntersectionObserver();
}

/**
 * Setup intersection observer for scroll-triggered animations
 */
function setupIntersectionObserver() {
    const observerOptions = {
        threshold: 0.1,
        rootMargin: '0px 0px -50px 0px'
    };
    
    const observer = new IntersectionObserver((entries) => {
        entries.forEach(entry => {
            if (entry.isIntersecting) {
                const element = entry.target;
                
                // Add animation class
                gsap.fromTo(element, {
                    opacity: 0,
                    y: 30
                }, {
                    opacity: 1,
                    y: 0,
                    duration: 0.6,
                    ease: "power2.out"
                });
                
                observer.unobserve(element);
            }
        });
    }, observerOptions);
    
    // Observe elements that should animate on scroll
    const animatedElements = document.querySelectorAll('.publication-card, .project-card, .honor-item');
    animatedElements.forEach(el => {
        observer.observe(el);
    });
}

/**
 * Utility function to debounce function calls
 * @param {Function} func - Function to debounce
 * @param {number} wait - Wait time in milliseconds
 * @returns {Function} Debounced function
 */
function debounce(func, wait) {
    let timeout;
    return function executedFunction(...args) {
        const later = () => {
            clearTimeout(timeout);
            func(...args);
        };
        clearTimeout(timeout);
        timeout = setTimeout(later, wait);
    };
}

/**
 * Handle external link clicks
 */
function setupExternalLinks() {
    const externalLinks = document.querySelectorAll('a[href^="http"], a[target="_blank"]');
    
    externalLinks.forEach(link => {
        link.addEventListener('click', function(e) {
            // Add loading state
            const originalText = this.textContent;
            this.textContent = 'Opening...';
            
            // Reset after a short delay
            setTimeout(() => {
                this.textContent = originalText;
            }, 1000);
        });
    });
}

/**
 * Setup keyboard navigation
 */
function setupKeyboardNavigation() {
    document.addEventListener('keydown', function(e) {
        if (isAnimating) return;
        
        const sections = ['about', 'research', 'projects', 'contact'];
        const currentIndex = sections.indexOf(currentSection);
        
        switch(e.key) {
            case 'ArrowLeft':
            case 'ArrowUp':
                e.preventDefault();
                if (currentIndex > 0) {
                    navigateToSection(sections[currentIndex - 1]);
                }
                break;
            case 'ArrowRight':
            case 'ArrowDown':
                e.preventDefault();
                if (currentIndex < sections.length - 1) {
                    navigateToSection(sections[currentIndex + 1]);
                }
                break;
            case 'Home':
                e.preventDefault();
                navigateToSection('about');
                break;
            case 'End':
                e.preventDefault();
                navigateToSection('contact');
                break;
        }
    });
}

/**
 * Setup CV download functionality
 */
function setupCVDownload() {
    const cvButton = document.querySelector('.cv-button');
    if (cvButton) {
        cvButton.addEventListener('click', function(e) {
            e.preventDefault();
            downloadCV();
        });
    }
}

/**
 * Download CV as PDF
 */
async function downloadCV() {
    try {
        // Show loading state
        const originalText = document.querySelector('.cv-button span').textContent;
        document.querySelector('.cv-button span').textContent = 'Generating PDF...';
        document.querySelector('.cv-button').style.pointerEvents = 'none';
        
        // Fetch the markdown content
        const response = await fetch('cv.md');
        const markdownText = await response.text();
        
        // Convert markdown to HTML
        const htmlContent = marked.parse(markdownText);
        
        // Create a temporary container for the CV
        const tempContainer = document.createElement('div');
        tempContainer.style.cssText = `
            position: absolute;
            left: -9999px;
            top: -9999px;
            width: 210mm;
            padding: 20mm;
            background: white;
            font-family: 'Source Serif Pro', serif;
            font-size: 12pt;
            line-height: 1.6;
            color: #333;
        `;
        
        // Add CSS styles for the CV
        const style = document.createElement('style');
        style.textContent = `
            .cv-content h1 { 
                font-size: 24pt; 
                color: #007BFF; 
                margin-bottom: 10pt; 
                border-bottom: 2pt solid #007BFF;
                padding-bottom: 5pt;
            }
            .cv-content h2 { 
                font-size: 18pt; 
                color: #333; 
                margin-top: 20pt; 
                margin-bottom: 10pt; 
            }
            .cv-content h3 { 
                font-size: 14pt; 
                color: #007BFF; 
                margin-top: 15pt; 
                margin-bottom: 8pt; 
            }
            .cv-content p { 
                margin-bottom: 8pt; 
                text-align: justify;
            }
            .cv-content ul { 
                margin-bottom: 10pt; 
                padding-left: 20pt;
            }
            .cv-content li { 
                margin-bottom: 4pt; 
            }
            .cv-content hr { 
                border: none; 
                border-top: 1pt solid #ccc; 
                margin: 15pt 0; 
            }
            .cv-content strong { 
                font-weight: bold; 
            }
            .cv-content em { 
                font-style: italic; 
            }
        `;
        
        tempContainer.innerHTML = `<div class="cv-content">${htmlContent}</div>`;
        document.body.appendChild(style);
        document.body.appendChild(tempContainer);
        
        // Convert to canvas and then to PDF
        const canvas = await html2canvas(tempContainer, {
            scale: 2,
            useCORS: true,
            allowTaint: true,
            backgroundColor: '#ffffff'
        });
        
        // Create PDF
        const { jsPDF } = window.jspdf;
        const pdf = new jsPDF('p', 'mm', 'a4');
        const imgData = canvas.toDataURL('image/png');
        
        const imgWidth = 210;
        const pageHeight = 295;
        const imgHeight = (canvas.height * imgWidth) / canvas.width;
        let heightLeft = imgHeight;
        
        let position = 0;
        
        pdf.addImage(imgData, 'PNG', 0, position, imgWidth, imgHeight);
        heightLeft -= pageHeight;
        
        while (heightLeft >= 0) {
            position = heightLeft - imgHeight;
            pdf.addPage();
            pdf.addImage(imgData, 'PNG', 0, position, imgWidth, imgHeight);
            heightLeft -= pageHeight;
        }
        
        // Download the PDF
        pdf.save('Cheng_Chen_CV.pdf');
        
        // Clean up
        document.body.removeChild(tempContainer);
        document.body.removeChild(style);
        
        // Reset button state
        document.querySelector('.cv-button span').textContent = originalText;
        document.querySelector('.cv-button').style.pointerEvents = 'auto';
        
        // Show success message
        showNotification('CV downloaded successfully!', 'success');
        
    } catch (error) {
        console.error('Error generating CV:', error);
        
        // Reset button state
        document.querySelector('.cv-button span').textContent = 'Download CV';
        document.querySelector('.cv-button').style.pointerEvents = 'auto';
        
        // Show error message
        showNotification('Error generating CV. Please try again.', 'error');
    }
}

/**
 * Show notification message
 */
function showNotification(message, type = 'info') {
    const notification = document.createElement('div');
    notification.style.cssText = `
        position: fixed;
        top: 20px;
        right: 20px;
        background: ${type === 'success' ? '#28a745' : type === 'error' ? '#dc3545' : '#007BFF'};
        color: white;
        padding: 12px 20px;
        border-radius: 8px;
        box-shadow: 0 4px 12px rgba(0, 0, 0, 0.15);
        z-index: 10000;
        font-weight: 500;
        transform: translateX(100%);
        transition: transform 0.3s ease;
    `;
    notification.textContent = message;
    
    document.body.appendChild(notification);
    
    // Animate in
    setTimeout(() => {
        notification.style.transform = 'translateX(0)';
    }, 100);
    
    // Remove after 3 seconds
    setTimeout(() => {
        notification.style.transform = 'translateX(100%)';
        setTimeout(() => {
            document.body.removeChild(notification);
        }, 300);
    }, 3000);
}

/**
 * Setup print functionality (removed - redundant with Download CV)
 */
function setupPrintFunctionality() {
    // Print functionality removed as it's redundant with the Download CV feature
    // Users can now download a PDF version of the CV instead
}

/**
 * Setup accessibility features
 */
function setupAccessibility() {
    // Add ARIA labels
    const navLinks = document.querySelectorAll('.nav-link');
    navLinks.forEach((link, index) => {
        link.setAttribute('aria-label', `Navigate to ${link.textContent.trim()}`);
        link.setAttribute('role', 'tab');
        link.setAttribute('tabindex', index === 0 ? '0' : '-1');
    });
    
    // Add ARIA labels to content sections
    const sections = document.querySelectorAll('.content-section');
    sections.forEach(section => {
        section.setAttribute('role', 'tabpanel');
        section.setAttribute('aria-hidden', section.classList.contains('active') ? 'false' : 'true');
    });
    
    // Update ARIA attributes when navigating
    const originalNavigateToSection = navigateToSection;
    navigateToSection = function(sectionId, updateHistory = true) {
        originalNavigateToSection(sectionId, updateHistory);
        
        // Update ARIA attributes
        const sections = document.querySelectorAll('.content-section');
        sections.forEach(section => {
            section.setAttribute('aria-hidden', section.id === sectionId ? 'false' : 'true');
        });
    };
}

/**
 * Setup performance optimizations
 */
function setupPerformanceOptimizations() {
    // Lazy load images
    const images = document.querySelectorAll('img[data-src]');
    const imageObserver = new IntersectionObserver((entries) => {
        entries.forEach(entry => {
            if (entry.isIntersecting) {
                const img = entry.target;
                img.src = img.dataset.src;
                img.removeAttribute('data-src');
                imageObserver.unobserve(img);
            }
        });
    });
    
    images.forEach(img => imageObserver.observe(img));
    
    // Preload next section content
    const preloadNextSection = debounce(() => {
        const sections = ['about', 'research', 'projects', 'contact'];
        const currentIndex = sections.indexOf(currentSection);
        const nextIndex = (currentIndex + 1) % sections.length;
        const nextSection = document.getElementById(sections[nextIndex]);
        
        if (nextSection && !nextSection.classList.contains('active')) {
            // Preload by making it visible but off-screen
            nextSection.style.position = 'absolute';
            nextSection.style.left = '-9999px';
            nextSection.style.visibility = 'hidden';
        }
    }, 1000);
    
    window.addEventListener('scroll', preloadNextSection);
}

// Initialize all features
document.addEventListener('DOMContentLoaded', function() {
    setupExternalLinks();
    setupKeyboardNavigation();
    setupCVDownload();
    setupPrintFunctionality();
    setupAccessibility();
    setupPerformanceOptimizations();
    
    console.log('All portfolio features initialized');
});

// Handle page visibility changes
document.addEventListener('visibilitychange', function() {
    if (document.hidden) {
        // Page is hidden, pause animations
        gsap.globalTimeline.pause();
    } else {
        // Page is visible, resume animations
        gsap.globalTimeline.resume();
    }
});

// Error handling
window.addEventListener('error', function(e) {
    console.error('Portfolio error:', e.error);
    
    // Fallback: ensure at least one section is visible
    const activeSection = document.querySelector('.content-section.active');
    if (!activeSection) {
        const aboutSection = document.getElementById('about');
        if (aboutSection) {
            aboutSection.classList.add('active');
            aboutSection.style.opacity = '1';
        }
    }
});

// Export functions for testing (if in Node.js environment)
if (typeof module !== 'undefined' && module.exports) {
    module.exports = {
        navigateToSection,
        setupNavigation,
        setupSmoothScrolling
    };
}
