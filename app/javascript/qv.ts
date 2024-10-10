type VoteType = "for" | "against";

type QuestionVotes = {
  questionId: string;
  votes: number;
  state: VoteType;
};

type Question = {
  id: string;
  question: string;
};

class NotEnoughCreditsError extends Error {
  constructor() {
    super("Not enough credits");
  }
}

class UserBallot {
  public questionsVotes: {
    [key: string]: QuestionVotes;
  };

  public availableCredits: number;

  constructor(questions: Question[], credits: number) {
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

  castVotes(voteType: VoteType, questionId: string, votes: number) {
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

const b = new UserBallot(
  [
    { id: "1", question: "q1" },
    { id: "2", question: "q2" },
  ],
  25,
);

b.castVotes("against", "1", 5);
b.castVotes("for", "1", 7);

b.dump();
