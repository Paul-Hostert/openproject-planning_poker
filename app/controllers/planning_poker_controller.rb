class PlanningPokerController < ApplicationController
  layout 'base'
  no_authorization_required! :index, :start_session, :vote, :next_story, :show_results, :join_session, :save_story_points, :restart_session
  skip_before_action :verify_authenticity_token

  before_action :find_project
  before_action :require_login
  before_action :check_session_active, only: [:vote, :show_results]

  def index
    @user_stories = @project.work_packages
                           .includes(:type, :status)
                           .where(status: Status.where(is_closed: false))
                           .order(:position, :created_at)

    @project_members = User.joins(:members)
                          .where(members: { project_id: @project.id })
                          .where(users: { status: 1 })
                          .distinct

    if @project_members.empty?
      @project_members = [User.current]
    end
    
    current_session = PlanningPokerSession.current_for_project(@project)
    
    if current_session
      @active_session_id = current_session.session_id
      @has_active_session = true
    else
      @active_session_id = nil
      @has_active_session = false
    end
  end

  def start_session
    init_poker_session

    PlanningPokerSession.where(project: @project, active: true).update_all(active: false)

    @poker_session[:session_id] = "#{@project.id}-#{Time.now.to_i}"
    @poker_session[:story_ids] = params[:story_ids] || []
    @poker_session[:participant_ids] = params[:participant_ids] || []
    @poker_session[:current_index] = 0
    
    if @poker_session[:story_ids].empty?
      flash[:error] = "Bitte wähle mindestens eine Story aus."
      redirect_to planning_poker_index_path(@project)
      return
    end
    
    PlanningPokerSession.create!(
      project: @project,
      session_id: @poker_session[:session_id],
      story_ids: @poker_session[:story_ids],
      active: true
    )

    redirect_to vote_planning_poker_index_path(@project)
  end

  def join_session
    init_poker_session
    
    current_session = PlanningPokerSession.current_for_project(@project)
    
    if current_session.nil?
      flash[:error] = "Keine aktive Planning Poker Session gefunden."
      redirect_to planning_poker_index_path(@project)
      return
    end
    
    @poker_session[:session_id] = current_session.session_id
    @poker_session[:story_ids] = current_session.story_ids
    @poker_session[:current_index] = 0
    
    redirect_to vote_planning_poker_index_path(@project)
  end

  def vote
    init_poker_session
    
    if @poker_session[:session_id].nil?
      current_session = PlanningPokerSession.current_for_project(@project)
      @poker_session[:session_id] = current_session&.session_id
    end
    
    if @poker_session[:story_ids].nil? || @poker_session[:story_ids].empty?
      if @poker_session[:session_id]
        current_session = PlanningPokerSession.find_by(session_id: @poker_session[:session_id])
        if current_session
          @poker_session[:story_ids] = current_session.story_ids
          @poker_session[:current_index] ||= 0
        else
          redirect_to planning_poker_index_path(@project)
          return
        end
      else
        redirect_to planning_poker_index_path(@project)
        return
      end
    end

    if request.post? && params[:value]
      PlanningPokerVote.create!(
        project: @project,
        work_package_id: current_story_id,
        user: User.current,
        session_id: @poker_session[:session_id],
        value: params[:value]
      )

      redirect_to vote_planning_poker_index_path(@project)
      return
    end

    @current_story = current_story
    @current_index = @poker_session[:current_index] || 0
    @total_stories = (@poker_session[:story_ids] || []).length
    
    existing_vote = PlanningPokerVote.find_by(
      session_id: @poker_session[:session_id],
      work_package_id: current_story_id,
      user: User.current
    )
    @selected_value = existing_vote&.value

    if @current_story.nil?
      redirect_to planning_poker_index_path(@project)
    end
  end

  def next_story
    init_poker_session

    @poker_session[:current_index] = (@poker_session[:current_index] || 0) + 1

    if @poker_session[:current_index] >= @poker_session[:story_ids].length
      redirect_to show_results_planning_poker_index_path(@project)
    else
      redirect_to vote_planning_poker_index_path(@project)
    end
  end

  def show_results
    init_poker_session
    
    if @poker_session[:session_id].nil?
      current_session = PlanningPokerSession.current_for_project(@project)
      @poker_session[:session_id] = current_session&.session_id
      
      if @poker_session[:session_id].nil?
        latest_vote = PlanningPokerVote.where(project: @project)
                                       .order(created_at: :desc)
                                       .first
        @poker_session[:session_id] = latest_vote&.session_id
      end
    end
    
    if @poker_session[:session_id].nil?
      redirect_to planning_poker_index_path(@project)
      return
    end
    
    all_votes = PlanningPokerVote.where(session_id: @poker_session[:session_id])
    
    @story_ids = all_votes.pluck(:work_package_id).uniq
    @stories = WorkPackage.where(id: @story_ids).includes(:type, :status)
    
    voter_ids = all_votes.pluck(:user_id).uniq
    @participants = User.where(id: voter_ids)
    
    @votes = {}
    all_votes.each do |vote|
      @votes[vote.work_package_id.to_s] ||= {}
      @votes[vote.work_package_id.to_s][vote.user_id.to_s] = vote.value
    end
  end

  def save_story_points
    init_poker_session
    
    if @poker_session[:session_id].nil?
      flash[:error] = "Keine aktive Session gefunden."
      redirect_to planning_poker_index_path(@project)
      return
    end
    
    test_story = WorkPackage.new
    has_direct_story_points = test_story.respond_to?(:story_points=)
    
    story_points_field = CustomField.find_by(
      type: 'WorkPackageCustomField',
      name: ['Story Points', 'Story points', 'StoryPoints', 'story points', 'story_points']
    )
    
    if !has_direct_story_points && story_points_field.nil?
      PlanningPokerSession.where(session_id: @poker_session[:session_id]).update_all(active: false)
      session[:planning_poker][@project.id] = {}
      
      flash[:error] = "Fehler: Es wurde kein Feld 'Story Points' gefunden. Bitte erstellen Sie zuerst ein Custom Field mit dem Namen 'Story Points' für Work Packages."
      redirect_to planning_poker_index_path(@project)
      return
    end
    
    all_votes = PlanningPokerVote.where(session_id: @poker_session[:session_id])
    
    story_ids = all_votes.pluck(:work_package_id).uniq
    stories = WorkPackage.where(id: story_ids)
    
    updated_count = 0
    failed_count = 0
    
    stories.each do |story|
      story_votes = all_votes.where(work_package_id: story.id)
                             .pluck(:value)
                             .reject { |v| ['?', '∞'].include?(v) }
                             .map(&:to_f)
      
      if story_votes.any?
        avg = (story_votes.sum / story_votes.size).round(1)
        rounded_points = avg.round
        
        begin
          if has_direct_story_points
            story.story_points = rounded_points
          elsif story_points_field
            story.custom_field_values = { story_points_field.id => rounded_points.to_s }
          end
          
          if story.save
            updated_count += 1
          else
            failed_count += 1
          end
        rescue => e
          failed_count += 1
        end
      end
    end
    
    PlanningPokerSession.where(session_id: @poker_session[:session_id]).update_all(active: false)
    session[:planning_poker][@project.id] = {}
    
    if failed_count > 0
      flash[:warning] = "#{updated_count} Story Points wurden eingetragen. #{failed_count} konnten nicht gespeichert werden."
    else
      flash[:notice] = "#{updated_count} Story Points wurden erfolgreich eingetragen."
    end
    
    redirect_to planning_poker_index_path(@project)
  end

  def restart_session
    init_poker_session
    
    if @poker_session[:session_id]
      PlanningPokerSession.where(session_id: @poker_session[:session_id]).update_all(active: false)
    end
    session[:planning_poker][@project.id] = {}
    
    flash[:notice] = "Planning Poker Session wurde beendet."
    redirect_to planning_poker_index_path(@project)
  end



  private

  def find_project
    @project = Project.find(params[:project_id])
  rescue ActiveRecord::RecordNotFound
    render_404
  end

  def init_poker_session
    session[:planning_poker] ||= {}
    session[:planning_poker][@project.id] ||= {}
    @poker_session = session[:planning_poker][@project.id]
  end

  def check_session_active
    init_poker_session
    
    if @poker_session[:session_id]
      active_session = PlanningPokerSession.where(
        session_id: @poker_session[:session_id],
        active: true
      ).exists?
      
      unless active_session
        session[:planning_poker][@project.id] = {}
        flash[:notice] = "Die Planning Poker Session wurde beendet."
        redirect_to planning_poker_index_path(@project)
      end
    end
  end

  def current_story_id
    return nil unless @poker_session[:story_ids] && @poker_session[:current_index]
    @poker_session[:story_ids][@poker_session[:current_index]]
  end

  def current_story
    return nil unless current_story_id
    WorkPackage.find_by(id: current_story_id)
  end
end
