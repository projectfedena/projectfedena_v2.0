class ExamScoresController < ApplicationController
  in_place_edit_for :exam_score, :score
end