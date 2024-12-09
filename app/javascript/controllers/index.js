import { application } from "./application"

import MenuController from "./menu_controller"
application.register("menu", MenuController)

import AlertController from "./alert_controller"
application.register("alert", AlertController)

import OnboardingController from "./onboarding_controller"
application.register("onboarding", OnboardingController)

import VotingController from "./voting_controller"
application.register("voting", VotingController)
