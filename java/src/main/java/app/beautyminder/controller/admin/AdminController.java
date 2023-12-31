package app.beautyminder.controller.admin;

import app.beautyminder.domain.Review;
import app.beautyminder.dto.ReviewStatusUpdateRequest;
import app.beautyminder.dto.chat.ChatKickDTO;
import app.beautyminder.dto.chat.ChatMessage;
import app.beautyminder.repository.ReviewRepository;
import app.beautyminder.service.MongoService;
import app.beautyminder.service.chat.WebSocketSessionManager;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.messaging.simp.SimpMessageSendingOperations;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.server.ResponseStatusException;

import java.util.Map;

@RestController
@RequestMapping("/admin")
@RequiredArgsConstructor
@PreAuthorize("hasRole('ROLE_ADMIN')")
public class AdminController {

    private final ReviewRepository reviewRepository;
    private final MongoService mongoService;
    private final SimpMessageSendingOperations messagingTemplate;
    private final WebSocketSessionManager webSocketSessionManager;

    @GetMapping("/hello")
    public String sayHello() {
        return "Hello admin";
    }

    @GetMapping("/reviews")
    public Page<Review> getAllReviews(@RequestParam(defaultValue = "0") int page,
                                      @RequestParam(defaultValue = "10") int size) {
        Pageable pageable = PageRequest.of(page, size);
        return reviewRepository.findAll(pageable);
    }

    @GetMapping("/reviews/denied")
    public Page<Review> getFilteredReviews(
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "10") int size
    ) {
        Pageable pageable = PageRequest.of(page, size);

        return reviewRepository.findAllFiltered(pageable);
    }

    @PatchMapping("/reviews/{reviewId}/status")
    public void updateReviewStatus(@PathVariable String reviewId, @RequestBody ReviewStatusUpdateRequest request) {
        boolean isFiltered = switch (request.status().toLowerCase()) {
            case "approved" -> false;
            case "denied" -> true;
            default -> throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Invalid status: " + request.status());
        };

        mongoService.updateFields(reviewId, Map.of("isFiltered", isFiltered), Review.class);
    }

    @PostMapping("/chat/kick")
    public ResponseEntity<?> kickUser(@RequestBody ChatKickDTO request) {
        if (webSocketSessionManager.isAlreadyConnected(request.username())) {
            var msg = ChatMessage.builder().message("You have been kicked out!").build();
            messagingTemplate.convertAndSendToUser(request.username(), "/queue/kick", msg);
            return ResponseEntity.ok().build();
        } else {
            return ResponseEntity.status(HttpStatus.NOT_FOUND).body("User not found or already disconnected.");
        }
    }

    @GetMapping("/chat/list")
    public ResponseEntity<?> listUser() {
        return ResponseEntity.ok(webSocketSessionManager.getConnectedUsers());
    }
}