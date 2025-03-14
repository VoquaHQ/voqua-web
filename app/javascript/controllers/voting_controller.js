import { Controller } from "@hotwired/stimulus";

// compiled from QV.ts
class NotEnoughCreditsError extends Error {
  constructor() {
    super("Not enough credits");
  }
}

class UserBallot {
  voteTypes = ["for", "against"];

  constructor(options, credits) {
    this.availableCredits = credits;
    this.optionsVotes = {};
    options.forEach((option) => {
      this.optionsVotes[option.id] = {
        optionId: option.id,
        votes: 0,
        state: "for",
      };
    });
  }

  votesForOption(optionId) {
    return this.optionsVotes[optionId].votes;
  }

  stateForOption(optionId) {
    return this.optionsVotes[optionId].state;
  }

  castVotes(voteType, optionId, votes) {
    const option = this.optionsVotes[optionId];
    // If the vote type is different from the current state
    if (voteType !== option.state) {
      const spentCredits = Math.pow(option.votes, 2);
      const votesToRemove = votes <= option.votes ? votes : option.votes;
      option.votes -= votesToRemove;
      const newSpentCredits = Math.pow(option.votes, 2);
      this.availableCredits += spentCredits - newSpentCredits;
      // decrease the actual votes we will add after
      votes -= votesToRemove;
      if (votes === 0) {
        return;
      }
      option.state = voteType;
    }
    const spentCredits = Math.pow(option.votes, 2);
    const totalCredits = Math.pow(option.votes + votes, 2);
    const creditsNeeded = totalCredits - spentCredits;
    if (creditsNeeded > this.availableCredits) {
      throw new NotEnoughCreditsError();
    }
    this.availableCredits -= creditsNeeded;
    option.votes += votes;
  }

  dump() {
    console.log({
      optionsVotes: this.optionsVotes,
      availableCredits: this.availableCredits,
    });
  }
}
// end compiled

class OptionBlock {
  constructor(element) {
    this.element = element;
    this.circles = {
      for: {},
      against: {},
    };
    this.setupCircles("for");
    this.setupCircles("against");
  }

  setupCircles(type) {
    const elements = this.element.querySelectorAll(
      `[data-credits-${type}] svg .credit.foreground`,
    );

    [...elements].reverse().forEach((element) => {
      const level = element.dataset.level;
      this.circles[type][level] ||= [];
      this.circles[type][level].push({
        element: element,
      });
    });
  }

  animate(voteType, votesForOption) {
    const levels = this.circles[voteType];

    for (const levelIndex in levels) {
      const levelCircles = levels[levelIndex];
      for (const circle of levelCircles) {
        circle.element.classList.add("hidden");
      }
    }

    for (let i = 1; i <= votesForOption; i++) {
      const levelCircles = levels[i.toString()];
      for (const circle of levelCircles) {
        circle.element.classList.remove("hidden");
      }
    }
  }
}

class CreditsAnimator {
  constructor(availableCredits, allCreditsContainer, optionsElements) {
    this.availableCredits = availableCredits;
    this.usedCredits = 0;
    this.allCreditsContainer = allCreditsContainer;
    this.blocks = this.setupBlocks(optionsElements);
    this.circles = this.setupCircles();
  }

  setupBlocks(optionsElements) {
    const blocks = {};
    optionsElements.forEach((optionElement) => {
      const optionId = optionElement.dataset.optionId;
      blocks[optionId] = new OptionBlock(optionElement);
    });

    return blocks;
  }

  setupCircles() {
    const elements = this.allCreditsContainer.querySelectorAll(
      "svg .credit.foreground",
    );

    const circles = {};

    [...elements].reverse().forEach((element, index) => {
      circles[index] = {};
      circles[index].element = element;
      circles[index].initialPosition = {
        x: element.getAttribute("cx"),
        y: element.getAttribute("cy"),
      };
    });

    return circles;
  }

  animate(optionId, voteType, votesForOption, newAvailableCredits) {
    let start = this.usedCredits;
    let end = this.availableCredits - newAvailableCredits;
    this.usedCredits = end;

    const func = start < end ? "add" : "remove";
    if (start > end) {
      [start, end] = [end, start];
    }

    for (let i = start; i < end; i++) {
      const element = this.circles[i].element;
      element.classList[func].call(element.classList, "used");
    }

    this.blocks[optionId].animate(voteType, votesForOption);
  }
}

class CreditsLabelAnimator {
  constructor(element, initialCredits) {
    this.element = element;
    this.credits = initialCredits;
  }

  animate(newCredits) {
    if (newCredits === this.credits) {
      return;
    }

    if (this.timeout) {
      clearTimeout(this.timeout);
    }

    const diff = newCredits - this.credits;
    const func = diff > 0 ? this.increment : this.decrement;
    const ms = 200 / Math.abs(diff);

    const loop = () => {
      if (this.credits === newCredits) {
        return;
      }

      func.call(this);
      this.timeout = setTimeout(loop, ms);
    };

    loop();
  }

  increment() {
    this.credits++;
    this.updateText();
  }

  decrement() {
    this.credits--;
    this.updateText();
  }

  updateText() {
    this.element.textContent = this.credits;
  }
}

export default class extends Controller {
  connect() {
    this.onVote = this.onVote.bind(this);
    this.handleFormSubmit = this.handleFormSubmit.bind(this);
    this.buttons = this.element.querySelectorAll("[data-vote-button]");
    this.form = this.element.querySelector("form");
    this.form.addEventListener("submit", this.handleFormSubmit);

    this.buttons.forEach((button) => {
      button.addEventListener("click", this.onVote);
    });

    this.optionsElements = this.element.querySelectorAll("[data-option-id]");
    this.options = Array.from(this.optionsElements).map((option) => {
      return {
        id: option.dataset.optionId,
      };
    });

    this.creditsElement = this.element.querySelector("[data-credits]");

    this.ballot = new UserBallot(this.options, 99);

    this.creditsLabelAnimator = new CreditsLabelAnimator(
      this.creditsElement,
      99,
    );
    this.creditsAnimator = new CreditsAnimator(
      this.ballot.availableCredits,
      this.element.querySelector("[data-all-credits]"),
      this.optionsElements,
    );

    this.updateCreditsCounter(this.element.querySelector("[data-credits]"));
    this.optionsElements.forEach((optionElement) => {
      const id = optionElement.dataset.optionId;
      optionElement
        .querySelectorAll("[data-votes-total-input]")
        .forEach((votesInputElement) => {
          const votesCount = parseInt(votesInputElement.value);
          const type = votesInputElement.dataset.votesTotalInput;
          if (votesCount > 0) {
            this.vote(id, type, votesCount);
          }
        });
    });
  }

  disconnect() {
    this.buttons.forEach((button) => {
      button.removeEventListener("click", this.onVote);
    });

    this.form.removeEventListener("submit", this.handleFormSubmit);
  }

  calculateUsedCreditsPercentage() {
    const totalCredits = 99;
    const usedCredits = totalCredits - this.ballot.availableCredits;
    return (usedCredits / totalCredits) * 100;
  }

  handleFormSubmit(event) {
    event.preventDefault();

    const percentageUsed = this.calculateUsedCreditsPercentage();

    if (percentageUsed < 80) {
      const remainingCredits = this.ballot.availableCredits;
      const shouldProceed = window.confirm(
        `Hey! You still have ${remainingCredits} voting points left!\n\n` +
          `Cool tip: You can vote multiple times on the things you really care about. ` +
          `More votes = stronger opinion!\n\n` +
          `Want to use more points or continue with your current votes?`,
      );

      if (!shouldProceed) {
        return;
      }
    }

    event.target.submit();
  }

  showErrorToast(message) {
    const toast = document.createElement("div");
    toast.className =
      "fixed top-4 right-4 bg-red-100 border-l-4 border-red-500 text-red-700 p-4 rounded shadow-lg z-50 transform transition-all duration-300 ease-in-out";
    toast.style.transform = "translateX(100%)";
    toast.style.opacity = "0";
    toast.innerHTML = `
      <div class="flex items-center">
        <div class="flex-shrink-0">
          <svg class="h-5 w-5 text-red-500" viewBox="0 0 20 20" fill="currentColor">
            <path fill-rule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zM8.707 7.293a1 1 0 00-1.414 1.414L8.586 10l-1.293 1.293a1 1 0 101.414 1.414L10 11.414l1.293 1.293a1 1 0 001.414-1.414L11.414 10l1.293-1.293a1 1 0 00-1.414-1.414L10 8.586 8.707 7.293z" clip-rule="evenodd"/>
          </svg>
        </div>
        <div class="ml-3">
          <p class="text-sm font-medium">${message}</p>
        </div>
      </div>
    `;

    document.body.appendChild(toast);

    // Animate in
    requestAnimationFrame(() => {
      toast.style.transform = "translateX(0)";
      toast.style.opacity = "1";
    });

    // Remove after 3 seconds
    setTimeout(() => {
      toast.style.transform = "translateX(100%)";
      toast.style.opacity = "0";
      toast.style.visibility = "hidden";
      setTimeout(() => {
        if (toast.parentNode) {
          document.body.removeChild(toast);
        }
      }, 300);
    }, 3000);
  }

  onVote(event) {
    event.preventDefault();
    const eButton = event.currentTarget;
    const eOption = eButton.closest("[data-option-id]");
    const eVoteType = eButton.closest("[data-vote-type]");

    const optionId = eOption.dataset.optionId;
    let voteType = eVoteType.dataset.voteType;

    try {
      this.vote(optionId, voteType, 1);
    } catch (error) {
      if (error instanceof NotEnoughCreditsError) {
        const currentVotes = this.ballot.votesForOption(optionId);
        const nextCost =
          Math.pow(currentVotes + 1, 2) - Math.pow(currentVotes, 2);
        const remainingCredits = this.ballot.availableCredits;
        this.showErrorToast(
          `Next vote on this option needs ${nextCost} credits - you have ${remainingCredits} left. Try voting on other options!`,
        );
      }
    }
  }

  vote(optionId, voteType, votesCount) {
    this.ballot.castVotes(voteType, optionId, votesCount);

    this.updateCreditsCounter();
    this.updateVoteCounters(optionId);
    this.updateOptionState(optionId);

    this.creditsAnimator.animate(
      optionId,
      this.ballot.stateForOption(optionId),
      this.ballot.votesForOption(optionId),
      this.ballot.availableCredits,
    );

    console.log(optionId, voteType);
    console.log(JSON.stringify(this.ballot));
  }

  updateCreditsCounter() {
    this.creditsElement.dataset.credits = this.ballot.availableCredits;
    this.creditsLabelAnimator.animate(this.ballot.availableCredits);
  }

  updateOptionState(optionId) {
    const state = this.ballot.stateForOption(optionId);
    const votes = this.ballot.votesForOption(optionId);
    let stateValue = "";

    if (votes > 0) {
      stateValue = state;
    }

    const optionElement = this.element.querySelector(
      `[data-option-id="${optionId}"]`,
    );

    optionElement.dataset.state = stateValue;
    if (votes > 1) {
      optionElement.classList.add("votes-plural");
    } else {
      optionElement.classList.remove("votes-plural");
    }
  }

  updateVoteCounters(optionId) {
    const option = this.ballot.optionsVotes[optionId];
    const optionElement = this.element.querySelector(
      `[data-option-id="${optionId}"]`,
    );
    const votesLabelElement = optionElement.querySelector(
      `[data-votes-total-label="${option.state}"]`,
    );

    const votesInputElement = optionElement.querySelector(
      `[data-votes-total-input="${option.state}"]`,
    );

    const votesLabelNumber = votesLabelElement.querySelector(".votes-number");
    votesLabelNumber.textContent = option.votes;

    votesInputElement.value = option.votes;
  }
}
