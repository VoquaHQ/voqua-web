import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  connect() {
    this.onVote = this.onVote.bind(this);
    this.buttons = this.element.querySelectorAll("[data-vote-button]");
    this.buttons.forEach((button) => {
      button.addEventListener("click", this.onVote);
    });
  }

  disconnect() {
    this.buttons.forEach((button) => {
      button.removeEventListener("click", this.onVote);
    });
  }

  onClick() {}

  onVote(event) {
    event.preventDefault();
    const eButton = event.currentTarget;
    const eQuestion = eButton.closest("[data-question-id]");
    const eVoteType = eButton.closest("[data-vote-type]");

    const questionId = eQuestion.dataset.questionId;
    const voteType = eVoteType.dataset.voteType;
    const voteDirection = eButton.dataset.voteButton;

    console.log(questionId, voteType, voteDirection);
  }
}
