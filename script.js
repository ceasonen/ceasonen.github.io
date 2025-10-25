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
            ease: "back.out(1.7)"
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
 * Setup print functionality
 */
function setupPrintFunctionality() {
    // Add print button functionality
    const printButton = document.createElement('button');
    printButton.innerHTML = '<i data-lucide="printer"></i> Print CV';
    printButton.className = 'print-button';
    printButton.style.cssText = `
        position: fixed;
        bottom: 20px;
        right: 20px;
        background: var(--accent-color);
        color: white;
        border: none;
        padding: 12px 20px;
        border-radius: 8px;
        cursor: pointer;
        font-weight: 500;
        box-shadow: 0 4px 12px rgba(0, 0, 0, 0.15);
        z-index: 1000;
        display: flex;
        align-items: center;
        gap: 8px;
        transition: all 0.3s ease;
    `;
    
    printButton.addEventListener('click', function() {
        window.print();
    });
    
    printButton.addEventListener('mouseenter', function() {
        this.style.transform = 'translateY(-2px)';
        this.style.boxShadow = '0 8px 25px rgba(0, 0, 0, 0.2)';
    });
    
    printButton.addEventListener('mouseleave', function() {
        this.style.transform = 'translateY(0)';
        this.style.boxShadow = '0 4px 12px rgba(0, 0, 0, 0.15)';
    });
    
    document.body.appendChild(printButton);
    
    // Re-initialize icons for the new button
    if (typeof lucide !== 'undefined') {
        lucide.createIcons();
    }
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
