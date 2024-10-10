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

  swapVoteType(voteType) {
    return voteType === "for" ? "against" : "for";
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
    const voteDirection = eButton.dataset.voteButton;

    if (voteDirection === "dec") {
      voteType = this.ballot.swapVoteType(voteType);
    }

    this.ballot.castVotes(voteType, questionId, 1);

    this.updateCreditsCounter();
    this.updateVoteCounters(questionId);

    console.log(questionId, voteType, voteDirection);
    console.log(JSON.stringify(this.ballot));
  }

  updateCreditsCounter() {
    this.creditsElement.textContent = this.ballot.availableCredits;
    this.creditsElement.dataset.credits = this.ballot.availableCredits;
  }

  updateVoteCounters(questionId) {
    const question = this.ballot.questionsVotes[questionId];
    const questionElement = this.element.querySelector(
      `[data-question-id="${questionId}"]`,
    );
    const votesElement = questionElement.querySelector(
      `[data-votes-total="${question.state}"]`,
    );

    votesElement.textContent = question.votes;
  }
}
