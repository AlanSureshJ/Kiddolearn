const colors = document.querySelectorAll(".color-wrapper");
const dropzones = document.querySelectorAll(".dropzone");
const scoreDisplay = document.getElementById("score");
const finalScore = document.getElementById("final-score");
const finalScoreValue = document.getElementById("final-score-value");
const replayButton = document.getElementById("replay-button");
const chosenColorDisplay = document.getElementById("chosen-color");

let score = 0;
let matchedColors = 0;
let matchedDropzones = new Set();
const maxScore = 60;

// ✅ Make all colors draggable
colors.forEach((color) => {
  color.setAttribute("draggable", "true");
  color.addEventListener("dragstart", dragStart);
});

dropzones.forEach((zone) => {
  zone.addEventListener("dragover", dragOver);
  zone.addEventListener("drop", dropColor);
});

// ✅ Drag Start: Store dragged color's ID
function dragStart(event) {
  if (!event.dataTransfer) {
    console.error("dataTransfer is null, drag operation cannot proceed.");
    return;
  }
  event.dataTransfer.setData("text/plain", event.target.dataset.color);
}

// ✅ Allow dragging over dropzone
function dragOver(event) {
  event.preventDefault();
}

// ✅ Drop logic with feedback
function dropColor(event) {
  event.preventDefault();
  const draggedColor = event.dataTransfer.getData("text/plain");
  const dropzoneColor = event.target.getAttribute("data-color");

  // ✅ Show the chosen color name correctly
  chosenColorDisplay.textContent = `You selected: ${draggedColor.charAt(0).toUpperCase() + draggedColor.slice(1)}`;

  if (matchedDropzones.has(event.target)) {
    return; // Prevent multiple drops in the same zone
  }

  if (draggedColor === dropzoneColor) {
    event.target.classList.add("correct");
    event.target.textContent = "✅ Correct!";
    playClapSound();
    increaseScore();
    launchCelebration();
    matchedColors++;

    matchedDropzones.add(event.target);
    event.target.style.pointerEvents = "none";
    setTimeout(() => resetDropzone(event.target), 2000);
  } else {
    event.target.classList.add("wrong");
    event.target.textContent = "❌ Oops! Try Again!";
    deductScore();
    setTimeout(() => resetDropzone(event.target), 2000);
  }

  updateScoreDisplay();

  if (matchedColors === colors.length) {
    showFinalScore();
  }
}

// ✅ Deduct Score for incorrect attempts
function deductScore() {
  score = Math.max(0, score - 5);
  updateScoreDisplay();
}

// ✅ Reset Dropzone
function resetDropzone(dropzone) {
  dropzone.classList.remove("correct", "wrong");
  dropzone.textContent = `Drop ${dropzone.getAttribute("data-color").charAt(0).toUpperCase() + dropzone.getAttribute("data-color").slice(1)} Here`;
  dropzone.style.pointerEvents = "auto";
}

// ✅ Celebration Animation
function launchCelebration() {
  confetti({
    particleCount: 100,
    angle: 90,
    spread: 180,
    origin: { x: 0.5, y: 0.5 },
    colors: ['#ff0000', '#00ff00', '#0000ff', '#ffff00', '#ff00ff']
  });
}

// ✅ Increase Score
function increaseScore() {
  score = Math.min(maxScore, score + 10);
  updateScoreDisplay();
}

// ✅ Play sound effect
function playClapSound() {
  new Audio("https://www.soundjay.com/button/beep-07.mp3").play();
}

// ✅ Show Final Score
function showFinalScore() {
  finalScore.style.display = "block";
  finalScoreValue.textContent = `${score} / ${maxScore}`;
  replayButton.style.display = "block";
}

// ✅ Shuffle Colors Randomly
function shuffleColors() {
  const colorsContainer = document.getElementById("colors");
  const colorElements = Array.from(colorsContainer.children);
  colorElements.sort(() => Math.random() - 0.5);
  colorElements.forEach((color) => colorsContainer.appendChild(color));
}

// ✅ Update Score Display
function updateScoreDisplay() {
  scoreDisplay.textContent = score;
}

// ✅ Initial Setup
shuffleColors();
