package app.beautyminder.service;

import app.beautyminder.domain.BaumannTest;
import app.beautyminder.repository.BaumannTestRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Optional;

@Slf4j
@RequiredArgsConstructor
@Service
public class BaumannTestService {
    private final BaumannTestRepository baumannTestRepository;

    public BaumannTest save(BaumannTest baumannTest) {
        return baumannTestRepository.save(baumannTest);
    }

    public Optional<BaumannTest> findById(String id) {
        return baumannTestRepository.findById(id);
    }

    public List<BaumannTest> findByUserId(String userId) {
        return baumannTestRepository.findByUserIdOrderByDateAsc(userId);
    }

    public boolean deleteByIdAndUserId(String id, String userId) {
        baumannTestRepository.deleteByIdAndUserId(id, userId);

        return findByUserId(userId).isEmpty();
    }
}