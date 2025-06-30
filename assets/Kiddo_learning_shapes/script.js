// Function to speak the shape name
// Function to say a friendly welcome message to kids

// Function to toggle background music
function toggleMusic() {
    const bgMusic = document.getElementById('bg-music');
    const musicToggleButton = document.getElementById('music-toggle');

    if (bgMusic.paused) {
        bgMusic.volume = 0.3; // Set initial volume to 20%
        bgMusic.play().then(() => {
            musicToggleButton.innerText = "Turn Music Off"; // Change button text
        }).catch((error) => {
            console.error("Music play blocked by browser:", error);
        });
    } else {
        bgMusic.pause();
        musicToggleButton.innerText = "Turn Music On"; // Change button text
    }
}



function sayWelcome() {
    const msg = new SpeechSynthesisUtterance("Hello Kiddos,, welcome to the fun world of shapes! Let's learn and play together!");
    
    // Set a kid-friendly voice (optional, based on system voices)
    const voices = window.speechSynthesis.getVoices();
    let selectedVoice = null;
    voices.forEach(function(voice) {
        if (voice.name === "Google UK English Female" || voice.name === "Google US English") {
            selectedVoice = voice;
        }
    });

    if (selectedVoice) {
        msg.voice = selectedVoice;  // Use the selected voice
    }

    // Set a cheerful and high-pitched voice for kids
    msg.pitch = 1.5;  // Higher pitch for a kid-friendly voice
    msg.rate = 1.1;   // Slightly faster to sound more lively
    window.speechSynthesis.speak(msg);
}

// Call the function to say the welcome message when the page loads
window.onload = function() {
    sayWelcome();
};

function speakShape(shapeName) {
    const msg = new SpeechSynthesisUtterance(shapeName);
    window.speechSynthesis.speak(msg);
}

// Function to generate random colors
function getRandomColor() {
    const letters = '0123456789ABCDEF';
    let color = '#';
    for (let i = 0; i < 6; i++) {
        color += letters[Math.floor(Math.random() * 16)];
    }
    return color;
}

// Function to show a Circle
function showCircle() {
    const shapeContainer = document.getElementById("shape-animation");
    shapeContainer.innerHTML = '';  // Clear previous shapes

    // Create SVG circle with random color
    const circle = document.createElementNS("http://www.w3.org/2000/svg", "circle");
    circle.setAttribute("cx", "150");
    circle.setAttribute("cy", "150");
    circle.setAttribute("r", "100");
    circle.classList.add("shape");
    circle.setAttribute("stroke", getRandomColor()); // Random color
    shapeContainer.appendChild(circle);

    // Speak the shape name
    document.getElementById("shape-name").innerText = "Circle";
    speakShape("Circle");
}

// Function to show a Square
function showSquare() {
    const shapeContainer = document.getElementById("shape-animation");
    shapeContainer.innerHTML = '';  // Clear previous shapes

    // Create SVG square with random color
    const square = document.createElementNS("http://www.w3.org/2000/svg", "rect");
    square.setAttribute("x", "50");
    square.setAttribute("y", "50");
    square.setAttribute("width", "200");
    square.setAttribute("height", "200");
    square.classList.add("shape");
    square.setAttribute("stroke", getRandomColor()); // Random color
    shapeContainer.appendChild(square);

    // Speak the shape name
    document.getElementById("shape-name").innerText = "Square";
    speakShape("Square");
}

// Function to show a Triangle
function showTriangle() {
    const shapeContainer = document.getElementById("shape-animation");
    shapeContainer.innerHTML = '';  // Clear previous shapes

    // Create SVG triangle with random color
    const triangle = document.createElementNS("http://www.w3.org/2000/svg", "polygon");
    triangle.setAttribute("points", "150,50 50,250 250,250");
    triangle.classList.add("shape");
    triangle.setAttribute("stroke", getRandomColor()); // Random color
    shapeContainer.appendChild(triangle);

    // Speak the shape name
    document.getElementById("shape-name").innerText = "Triangle";
    speakShape("Triangle");
}

// Function to show a Rectangle
function showRectangle() {
    const shapeContainer = document.getElementById("shape-animation");
    shapeContainer.innerHTML = '';  // Clear previous shapes

    // Create SVG rectangle with random color
    const rectangle = document.createElementNS("http://www.w3.org/2000/svg", "rect");
    rectangle.setAttribute("x", "50");
    rectangle.setAttribute("y", "50");
    rectangle.setAttribute("width", "200");
    rectangle.setAttribute("height", "100");
    rectangle.classList.add("shape");
    rectangle.setAttribute("stroke", getRandomColor()); // Random color
    shapeContainer.appendChild(rectangle);

    // Speak the shape name
    document.getElementById("shape-name").innerText = "Rectangle";
    speakShape("Rectangle");
}
// Function to show a Star
function showStar() {
    const shapeContainer = document.getElementById("shape-animation");
    shapeContainer.innerHTML = '';  // Clear previous shapes

    // Create SVG star with random color
    const star = document.createElementNS("http://www.w3.org/2000/svg", "polygon");
    star.setAttribute("points", "150,25 179,111 270,111 196,165 223,251 150,200 77,251 104,165 30,111 121,111");
    star.classList.add("shape");
    star.setAttribute("stroke", getRandomColor()); // Random color
    shapeContainer.appendChild(star);

    // Speak the shape name
    document.getElementById("shape-name").innerText = "Star";
    speakShape("Star");
}

// Function to show an Oval
function showOval() {
    const shapeContainer = document.getElementById("shape-animation");
    shapeContainer.innerHTML = '';  // Clear previous shapes

    // Create SVG oval with random color
    const oval = document.createElementNS("http://www.w3.org/2000/svg", "ellipse");
    oval.setAttribute("cx", "150");
    oval.setAttribute("cy", "150");
    oval.setAttribute("rx", "100");
    oval.setAttribute("ry", "60");
    oval.classList.add("shape");
    oval.setAttribute("stroke", getRandomColor()); // Random color
    shapeContainer.appendChild(oval);

    // Speak the shape name
    document.getElementById("shape-name").innerText = "Oval";
    speakShape("Oval");
}
