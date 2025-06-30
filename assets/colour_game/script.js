const colors = ["red", "blue", "yellow", "green", "pink", "purple", "brown", "black", "white", "grey"];
let score = 0;
let currentColor = "";
let usedColors = [];
const music = document.getElementById("bg-music");
const musicBtn = document.getElementById("music-btn");

// Set initial volume (lower than speech)
music.volume = 0.3;
music.play(); // Start music when game loads

// Toggle music on/off
musicBtn.addEventListener("click", () => {
    if (music.paused) {
        music.play();
        musicBtn.innerText = "🔊 Music: ON";
    } else {
        music.pause();
        musicBtn.innerText = "🔇 Music: OFF";
    }
});

// Function to shuffle an array (Fisher-Yates Shuffle)
function shuffleArray(array) {
    for (let i = array.length - 1; i > 0; i--) {
        let j = Math.floor(Math.random() * (i + 1));
        [array[i], array[j]] = [array[j], array[i]]; // Swap elements
    }
}

// Function to generate a random color for the question
function generateQuestion() {
    if (usedColors.length === colors.length) {
        showFinalScore();
        return;
    }

    // Pick a new color that hasn't been used
    do {
        currentColor = colors[Math.floor(Math.random() * colors.length)];
    } while (usedColors.includes(currentColor));
    
    usedColors.push(currentColor);
    document.getElementById("question").innerText = `Find: ${currentColor.toUpperCase()}`;

    generateButtons();
}

// Function to generate shuffled color buttons
function generateButtons() {
    const container = document.getElementById("buttons-container");
    container.innerHTML = ""; 

    let options = new Set();
    options.add(currentColor);

    while (options.size < 5) {
        let randomColor = colors[Math.floor(Math.random() * colors.length)];
        options.add(randomColor);
    }

    let shuffledOptions = Array.from(options);
    shuffleArray(shuffledOptions);  // 🔀 Shuffle before displaying

    shuffledOptions.forEach(color => {
        const button = document.createElement("button");
        button.dataset.color = color;
        button.style.backgroundColor = color;

        button.classList.add("color-button");

        button.addEventListener("click", () => checkAnswer(button, color));
        container.appendChild(button);
    });

    document.getElementById("next-btn").style.display = "block";
}

// Function to check if the answer is correct
function checkAnswer(button, selectedColor) {
    if (selectedColor === currentColor) {
        score += 10;
        speak("Very good Kiddo!");
        confettiEffect();
        document.getElementById("score").innerText = `Score: ${score}`;

        document.querySelectorAll("#buttons-container button").forEach(btn => btn.disabled = true);

        setTimeout(generateQuestion, 1000);  
    } else {
        score -= 1;
        document.getElementById("score").innerText = `Score: ${score}`;
        speak("Please Try again..!");
        
        button.classList.add("shake");
        setTimeout(() => button.classList.remove("shake"), 500);
    }
}

// Function to skip the current question
function skipQuestion() {
    generateQuestion();
}

// Function to show final score
function showFinalScore() {
    let message = `Your final score is ${score} out of 100. `;
    
    if (score >= 80) {
        message += "Wow dear! You're a color expert! ";
    } else if (score >= 50) {
        message += "Great job dear! Keep practicing! ";
    } else {
        message += "Nice try dear! Play again to improve! ";
    }

    document.getElementById("question").innerText = message;
    speak(message);

    document.getElementById("buttons-container").innerHTML = "";
    document.getElementById("next-btn").style.display = "none";

    let replayBtn = document.createElement("button");
    replayBtn.innerText = "Play Again 🔄";
    replayBtn.id = "replay-btn";
    replayBtn.addEventListener("click", () => location.reload());
    document.querySelector(".game-container").appendChild(replayBtn);
}

// Function to trigger confetti 🎉
function confettiEffect() {
    confetti({
        particleCount: 100,
        spread: 70,
        origin: { y: 0.6 }
    });
}

// Function for text-to-speech feedback
function speak(message) {
    let speech = new SpeechSynthesisUtterance(message);
    speech.lang = "en-US";
    window.speechSynthesis.speak(speech);
}

// Attach event to "Next" button
document.getElementById("next-btn").addEventListener("click", skipQuestion);

// Start the game
generateQuestion();
