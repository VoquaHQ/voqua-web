import { Controller } from "@hotwired/stimulus";

// compiled from QV.ts
class NotEnoughCreditsError extends Error {
  constructor() {
    super("Not enough credits");
  }
}

class UserBallot {
  voteTypes = ["for", "against"];

  constructor(questions, credits) {
    this.availableCredits = credits;
    this.questionsVotes = {};
    questions.forEach((question) => {
      this.questionsVotes[question.id] = {
        questionId: question.id,
        votes: 0,
        state: "for",
      };
    });
  }

  votesForQuestion(questionId) {
    return this.questionsVotes[questionId].votes;
  }

  stateForQuestion(questionId) {
    return this.questionsVotes[questionId].state;
  }

  castVotes(voteType, questionId, votes) {
    const question = this.questionsVotes[questionId];
    // If the vote type is different from the current state
    if (voteType !== question.state) {
      const spentCredits = Math.pow(question.votes, 2);
      const votesToRemove = votes <= question.votes ? votes : question.votes;
      question.votes -= votesToRemove;
      const newSpentCredits = Math.pow(question.votes, 2);
      this.availableCredits += spentCredits - newSpentCredits;
      // decrease the actual votes we will add after
      votes -= votesToRemove;
      if (votes === 0) {
        return;
      }
      question.state = voteType;
    }
    const spentCredits = Math.pow(question.votes, 2);
    const totalCredits = Math.pow(question.votes + votes, 2);
    const creditsNeeded = totalCredits - spentCredits;
    if (creditsNeeded > this.availableCredits) {
      throw new NotEnoughCreditsError();
    }
    this.availableCredits -= creditsNeeded;
    question.votes += votes;
  }

  dump() {
    console.log({
      questionsVotes: this.questionsVotes,
      availableCredits: this.availableCredits,
    });
  }
}
// end compiled

class QuestionBlock {
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

  animate(voteType, votesForQuestion) {
    const levels = this.circles[voteType];

    for (const levelIndex in levels) {
      const levelCircles = levels[levelIndex];
      for (const circle of levelCircles) {
        circle.element.classList.add("hidden");
      }
    }

    for (let i = 1; i <= votesForQuestion; i++) {
      const levelCircles = levels[i.toString()];
      for (const circle of levelCircles) {
        circle.element.classList.remove("hidden");
      }
    }
  }
}

class CreditsAnimator {
  constructor(availableCredits, allCreditsContainer, questionsElements) {
    this.availableCredits = availableCredits;
    this.usedCredits = 0;
    this.allCreditsContainer = allCreditsContainer;
    this.blocks = this.setupBlocks(questionsElements);
    this.circles = this.setupCircles();
  }

  setupBlocks(questionsElements) {
    const blocks = {};
    questionsElements.forEach((questionElement) => {
      const questionId = questionElement.dataset.questionId;
      blocks[questionId] = new QuestionBlock(questionElement);
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

  animate(questionId, voteType, votesForQuestion, newAvailableCredits) {
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
      // this.moveElementToX(element, 500);
    }

    this.blocks[questionId].animate(voteType, votesForQuestion);
  }

  moveElementToX(element, x) {
    const delay = 1000;
    element.style.transition = `transform ${delay}ms ease-out, opacity 1s ease-out`;
    element.style.transform = `translate(${x}px, 100px)`;

    // Remove the transition after completion to allow subsequent manual changes
    setTimeout(() => {
      element.style.transition = "";
      console.log("done");
      // element.classList["add"].call(element.classList, "used");
    }, delay);
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
    this.buttons = this.element.querySelectorAll("[data-vote-button]");
    this.buttons.forEach((button) => {
      button.addEventListener("click", this.onVote);
    });

    this.questionsElements =
      this.element.querySelectorAll("[data-question-id]");
    this.questions = Array.from(this.questionsElements).map((question) => {
      return {
        id: question.dataset.questionId,
      };
    });

    this.creditsElement = this.element.querySelector("[data-credits]");

    this.ballot = new UserBallot(this.questions, 99);

    this.creditsLabelAnimator = new CreditsLabelAnimator(
      this.creditsElement,
      99,
    );
    this.creditsAnimator = new CreditsAnimator(
      this.ballot.availableCredits,
      this.element.querySelector("[data-all-credits]"),
      this.questionsElements,
    );

    this.updateCreditsCounter(this.element.querySelector("[data-credits]"));
    this.questionsElements.forEach((questionElement) => {
      const id = questionElement.dataset.questionId;
      questionElement
        .querySelectorAll("[data-votes-total-input]")
        .forEach((votesInputElement) => {
          const votesCount = parseInt(votesInputElement.value);
          const type = votesInputElement.dataset.votesTotalInput;
          this.vote(id, type, votesCount);
        });
    });
  }

  disconnect() {
    this.buttons.forEach((button) => {
      button.removeEventListener("click", this.onVote);
    });
  }

  onVote(event) {
    event.preventDefault();
    const eButton = event.currentTarget;
    const eQuestion = eButton.closest("[data-question-id]");
    const eVoteType = eButton.closest("[data-vote-type]");

    const questionId = eQuestion.dataset.questionId;
    let voteType = eVoteType.dataset.voteType;

    this.vote(questionId, voteType, 1);
  }

  vote(questionId, voteType, votesCount) {
    this.ballot.castVotes(voteType, questionId, votesCount);

    this.updateCreditsCounter();
    this.updateVoteCounters(questionId);
    this.updateQuestionState(questionId);

    this.creditsAnimator.animate(
      questionId,
      this.ballot.stateForQuestion(questionId),
      this.ballot.votesForQuestion(questionId),
      this.ballot.availableCredits,
    );

    console.log(questionId, voteType);
    console.log(JSON.stringify(this.ballot));
  }

  updateCreditsCounter() {
    this.creditsElement.dataset.credits = this.ballot.availableCredits;
    this.creditsLabelAnimator.animate(this.ballot.availableCredits);
  }

  updateQuestionState(questionId) {
    const state = this.ballot.stateForQuestion(questionId);
    const votes = this.ballot.votesForQuestion(questionId);
    let stateValue = "";

    if (votes > 0) {
      stateValue = state;
    }

    const questionElement = this.element.querySelector(
      `[data-question-id="${questionId}"]`,
    );

    questionElement.dataset.state = stateValue;
  }

  updateVoteCounters(questionId) {
    const question = this.ballot.questionsVotes[questionId];
    const questionElement = this.element.querySelector(
      `[data-question-id="${questionId}"]`,
    );
    const votesLabelElement = questionElement.querySelector(
      `[data-votes-total-label="${question.state}"]`,
    );

    const votesInputElement = questionElement.querySelector(
      `[data-votes-total-input="${question.state}"]`,
    );

    votesLabelElement.textContent = question.votes;
    console.log(votesInputElement);
    votesInputElement.value = question.votes;
  }
}
