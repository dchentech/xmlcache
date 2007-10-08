class DirectorController < ApplicationController
	def all
		@directors = Director.find(:all)
	end
	
	def show
		@director = Director.find(params[:id])
	end
end